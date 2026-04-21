%% Make a fresh detector
net_path = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX_rap.mat";
labels = "USV";
settings = spectrogram_settings();
blank_YOLOX = generate_blank_YOLOX(net_path, settings, labels);

%% Generate training data
man_curation_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/";
train_img_root = "/home/lapishla/Documents/training_images/RAP/";
train_path = fullfile(man_curation_path, 'train');
val_path = fullfile(man_curation_path, 'validation');
generate_training_data(train_path, train_img_root, val_path=val_path, labels=labels, spectrogram_settings=settings)

%% Train the detector
network = train_detector(train_img_root, net_path, save_path=net_path);

%% Run predictions on validation audio 
validation_audio = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/validation/";
prediction_path = fullfile(tempdir, 'val_predictions');
batch_detect_calls(validation_audio, prediction_path, network)

%% Report performance on validation audio
[score, details] = detection_performance(val_path, prediction_path)