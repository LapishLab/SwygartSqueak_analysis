function network = train_detector(train_folder, validation_folder, net_path, opts)
arguments
    train_folder string
    validation_folder string
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
[~] = mkdir(Checkpoint_path);

% Load existing network
network = load(net_path);

% Load data
train = load_datastore(train_folder,  network.detector.ClassNames);
val = load_datastore(validation_folder,  network.detector.ClassNames);

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

% Train the YOLO v2 network.
[detector,info] = trainYOLOXObjectDetector(train,network.detector,op);

network.detector = detector;
network.info = info;
network.training_options = op;


save(opts.save_path, '-struct', "network")
end

function data = load_datastore(folder, class_names)
    % load and concatonate TTables
    fnames = {dir(fullfile(folder,"*.mat")).name};
    ttables = table();
    for i=1:length(fnames)
        d = load(fullfile(folder,fnames{i}));
        ttables = cat(1, ttables, d.TTable);
    end
    ttables = ttables(~cellfun(@isempty, ttables.Labels), :);

    % Make sure all categorical variables have the required classnames in
    % their metadata, otherwise Matlab might throw a completely pointless
    % error that is incredibly hard to debug and ruins your evening
    add_classnames = @(x) addcats(x, class_names);
    ttables.Labels = cellfun(add_classnames, ttables.Labels, 'UniformOutput', false);

    % Convert to datastore
    blds = boxLabelDatastore( ttables(:,{'Boxes','Labels'}));
    imds = imageDatastore(string(ttables.imageFilename));
    data = combine(imds, blds);
end