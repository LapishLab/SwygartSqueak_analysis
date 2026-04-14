clear
% net = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX2026-02-26_08-17-26.mat";
% train = "/home/lapishla/Desktop/training/training_images/";
% validate = "/home/lapishla/Desktop/training/validation_images/";

train = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/detection_files/train/";
validate = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/detection_files/validation/";

% train_img = "/home/lapishla/Desktop/training_images/train";
% validate_img = "/home/lapishla/Desktop/training_images/validation";
train_img = "/home/lapishla/Desktop/training_images_DD/train";
validate_img = "/home/lapishla/Desktop/training_images_DD/validation";

network2 = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");

settings = spectrogram_settings();

%% Create training images
det = load_all_detection(train);
det.Calls = cellfun(@merge_types, det.Calls, UniformOutput=false);
det.Calls = cellfun(@filter_calls, det.Calls, UniformOutput=false);
summary(cat(1, det.Calls{:}).Type)
im_train = create_training_images(det,train_img,settings);

det = load_all_detection(validate);
det.Calls = cellfun(@merge_types, det.Calls, UniformOutput=false);
det.Calls = cellfun(@filter_calls, det.Calls, UniformOutput=false);
summary(cat(1, det.Calls{:}).Type)
im_val = create_training_images(det,validate_img,settings);

%% Train the detector
network = train_detector(train_img, validate_img, net);
%% Run validation on the generated images

network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34_checkpoint/net_checkpoint__30__2026_04_09__11_49_34.mat");
network.detector = network.net;
network.settings = settings;
[score,details,l] = detect_pregenerated_images(network.net,im_val);


%% run detector on audio files
%%
%prediction_output = "/home/lapishla/Desktop/Prat_all_predictions/";
prediction_output = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/validation/";
network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");
network.settings = spectrogram_settings();
audio_root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/";
%%
audio_folder = audio_root + "train/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "test/";
batch_detect_calls(audio_folder, prediction_output, network)
%%
audio_folder = audio_root + "validation/";
batch_detect_calls(audio_folder, prediction_output, network)
%

function calls = merge_types(calls)
label = string(calls.Type);
isUSV = contains(label, 'USV');
label(isUSV) = 'USV';
label(~isUSV) = 'noise';
calls.Type = categorical(label);
end