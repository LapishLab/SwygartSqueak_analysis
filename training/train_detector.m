function network = train_detector(training_img_path, net_path, opts)
arguments
    training_img_path string
    net_path string
    opts.save_path {mustBeTextScalar}
end

% Save network to same folder as original net with added timestamp
if ~isfield(opts, 'save_path')
    [net_folder, net_name, ext] = fileparts(net_path);
    timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HH-mm-ss'));
    opts.save_path = fullfile(net_folder, net_name+"_"+timestamp+ext);
end

% Set checkpoint directory
[folder,file,~] = fileparts(opts.save_path);
Checkpoint_path = fullfile(folder, file+"_checkpoint");
[~,~] = mkdir(Checkpoint_path);

% Load existing network
network = load(net_path);

% Load training data for all folders (rows = detection files)
training_data = table();
for i=1:length(training_img_path)
    training_data = cat(1, training_data, load_training_data(training_img_path(i)));
end

% split into validation and training
train = training_data(strcmpi(training_data.group, "train"), :);
val =  training_data(strcmpi(training_data.group, "validation"), :);

% convert to datastores
train = detections2datatore(train);
val = detections2datatore(val);

% Set up training options
op = trainingOptions('sgdm');
op.InitialLearnRate=0.001;
op.MiniBatchSize= 8;
op.MaxEpochs = 100;
op.Shuffle='every-epoch'; %(default once)
op.CheckpointFrequencyUnit='iteration';
op.CheckpointFrequency=10;
op.ValidationFrequency=10; %Unit in iterations
op.Plots='training-progress';     
op.ValidationData=val;
op.CheckpointPath = Checkpoint_path;
op.OutputNetwork='best-validation';

% Train the YOLOX network.
[detector,info] = trainYOLOXObjectDetector(train,network.detector,op);

% Save the resulting network
network.detector = detector;
network.info = info;
network.training_options = op;
save(opts.save_path, '-struct', "network")
end

function datastore = detections2datatore(detections)
im_table = cat(1, detections.image_table{:});
im_table(cellfun(@isempty, im_table.Boxes),:) = [];
imds = imageDatastore(string(im_table.imageFilename));
blds = boxLabelDatastore(im_table(:,{'Boxes','Labels'}));
datastore = combine(imds, blds);
end

function detections = load_training_data(folder)
detections = load(fullfile(folder, "file_info.mat")).detections;
subfolder = fullfile(folder,detections.id);
 
for i=1:height(detections)
    % Load image info table
    img_info_path = fullfile(subfolder(i), "image_info.mat");
    if ~exist(img_info_path, 'file')
        error("image_info.mat not found for %s", subfolder(i))
    end
    im_tbl = load(img_info_path).image_table;
    
    % Recreate imageFilePaths as relative to avoid errors if data was moved
    [~, name,ext] = fileparts(im_tbl.imageFilename);
    im_tbl.imageFilename = fullfile(subfolder(i), name+ext);

    % Check that images exist
    not_exist = ~cellfun(@exist, im_tbl.imageFilename);
    if any(not_exist)
        error("The following images were missing:\n %s \n", ...
            strjoin(im_tbl.imageFilename(not_exist), ' \n '));
    end

    % Save image table into detections
    detections.image_table{i} = im_tbl;
end

end