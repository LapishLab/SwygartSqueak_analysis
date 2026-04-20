%% All paths
net_path = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX_rap.mat";

% Allow for more than 1 manual curation path
man_curation_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/";
audio_root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/";

train_img_root = "/home/lapishla/Documents/training_images/RAP/";
predictions_path = "/home/lapishla/Documents/predictions/RAP/";
%% Make a fresh detector
labels = "USV";
settings = spectrogram_settings();
blank_YOLOX = generate_blank_YOLOX(net_path, settings, labels);

%% Create training images (for training data)
det_path = fullfile(man_curation_path, 'train');
img_path_train = fullfile(train_img_root, 'train');

det = load_all_detection(det_path);
det.Calls = uniform_call_labels(det.Calls, labels);
det.Calls = cellfun(@filter_calls, det.Calls, UniformOutput=false);
summary(cat(1, det.Calls{:}).Type)
create_training_images(det,img_path_train, blank_YOLOX.settings);

%% Create training images (for validation data)
det_path = fullfile(man_curation_path, 'validation');
img_path_val = fullfile(train_img_root, 'validation');

det = load_all_detection(det_path);
det.Calls = uniform_call_labels(det.Calls, labels);
det.Calls = cellfun(@filter_calls, det.Calls, UniformOutput=false);
summary(cat(1, det.Calls{:}).Type)
im_val = create_training_images(det,img_path_val, blank_YOLOX.settings);

%% Train the detector
network = train_detector(img_path_train, img_path_val, net_path, save_path=net_path);

%% Run validation on the generated images
[score,details,l] = detect_pregenerated_images(network.detector,im_val);

%% run detector
audio_folder = audio_root + "train/";
batch_detect_calls(audio_folder, predictions_path, network)

audio_folder = audio_root + "test/";
batch_detect_calls(audio_folder, predictions_path, network)

audio_folder = audio_root + "validation/";
batch_detect_calls(audio_folder, predictions_path, network)

