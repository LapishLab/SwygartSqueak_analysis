function generate_training_data(train_path, output_path, opts)
arguments
    train_path {mustBeTextScalar} % Path to folder containing training data
    output_path {mustBeTextScalar} % Where to save the data
    opts.val_path {mustBeTextScalar} % Path to folder containing validation data
    opts.labels {mustBeText} = "USV" % Which labels to use
    opts.filter_func = @filter_calls
    opts.spectrogram_settings = spectrogram_settings();
end

%% Load all detection files (training & validation) and merge
det_train = load_all_detection(train_path);
det_val = load_all_detection(opts.val_path);

all_det = cat(1, det_val, det_train);
all_det.group = repmat("train", height(all_det), 1);
all_det.group(1:height(det_val)) = repmat("validation", height(det_val), 1);

%% Verify Unified call labels 
all_det.Calls = uniform_call_labels(all_det.Calls, opts.labels);
all_det.Calls = cellfun(opts.filter_func, all_det.Calls, UniformOutput=false);

%% Drop files with 0 calls
no_calls = cellfun(@isempty, all_det.Calls);
fprintf("Dropping the following files which contain 0 valid calls:\n  %s \n", ...
    strjoin(all_det.file_names(no_calls), ' \n  '))
all_det(no_calls, :) = [];

%% Get unique IDs from detection filenames
[~, all_det.id, ~] = fileparts(all_det.file_names);
duplicates = find_duplicates(all_det.id);
if ~isempty(duplicates)
    error("Extracted IDs are not unique: %s", strjoin(string(duplicates), ', '));
end

%% Save file information to mat file
[~,~] = mkdir(output_path);
file_info = struct();
file_info.settings = opts.spectrogram_settings;
file_info.detections = all_det;
save(fullfile(output_path,'file_info.mat'),'-struct', "file_info");

%% loop through each detection file and save images to subfolder
subfolder = fullfile(output_path, all_det.id);
image_info_mat = fullfile(subfolder, "image_info.mat");

num_det = height(all_det);
settings = opts.spectrogram_settings;
parfor k = 1:num_det
    row = all_det(k,:);
    if exist(image_info_mat(k), "file")
        fprintf("training images already exist for %s: skipping\n", row.id)
        continue;
    end

    calls = row.Calls{1};
    fprintf("Generating images for %s (%i/%i): %i calls \n", ...
        row.id, k, num_det, height(calls))
    audioFile = row.audiodata{1}.Filename;
    generate_images(audioFile, calls, subfolder(k), settings)
end
fprintf("Training data generation complete!\n")
end

function duplicates = find_duplicates(x)
    [u, ~, ic] = unique(x);
    counts = accumarray(ic, 1); % Count occurrences of each unique value
    duplicates = u(counts > 1); % Values that appear more than once
end