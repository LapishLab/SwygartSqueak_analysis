%% Make a fresh detector
net_path = "/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX_rap.mat";
labels = "USV";
settings = spectrogram_settings();
blank_YOLOX = generate_blank_YOLOX(net_path, settings, labels);

%% Generate training data for RAP project
rap_curation_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/detection_files/";
rap_training_data = "/home/lapishla/Documents/training_images/RAP/";
train_path = fullfile(rap_curation_path, 'train');
rap_val_path = fullfile(rap_curation_path, 'validation');
generate_training_data(train_path, rap_training_data, val_path=rap_val_path, labels=labels, spectrogram_settings=settings)

%% Generate training data for DD project
DD_curation_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/detection_files/";
DD_training_data = "/home/lapishla/Documents/training_images/DD/";
train_path = fullfile(DD_curation_path, 'train');
dd_val_path = fullfile(DD_curation_path, 'validation');
generate_training_data(train_path, DD_training_data, val_path=dd_val_path, labels=labels, spectrogram_settings=settings)

%% Generate training data for Wistar RAP project
wrap_curation_path = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyRAP/Wistar_Urgency/detection_files/";
wrap_training_data = "/home/lapishla/Documents/training_images/wistar_RAP/";
train_path = fullfile(wrap_curation_path, 'train');
wrap_val_path = fullfile(wrap_curation_path, 'validation');
generate_training_data(train_path, wrap_training_data, val_path=wrap_val_path, labels=labels, spectrogram_settings=settings)

%% Train the detector (include paths to all 3 sets of training data)
training_data = [rap_training_data, DD_training_data, wrap_training_data];
network = train_detector(training_data, net_path, save_path=net_path);

%% Run predictions on rap validation audio and report performance
validation_audio = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/Prat_Urgency/audio/validation/";
rap_predictions = fullfile(tempdir, 'rap_predictions');
batch_detect_calls(validation_audio, rap_predictions, network)
[rap_score, rap_details] = detection_performance(rap_val_path, rap_predictions,min_score=0.75);

%% Run predictions on DD validation audio and report performance
validation_audio = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/validation/";
dd_predictions = fullfile(tempdir, 'dd_predictions');
batch_detect_calls(validation_audio, dd_predictions, network)
[dd_score, dd_details] = detection_performance(dd_val_path, dd_predictions, min_score=0.75);

%% Run predictions on rap validation audio and report performance
validation_audio = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyRAP/Wistar_Urgency/audio/validation/";
wrap_predictions = fullfile(tempdir, 'wrap_predictions');
batch_detect_calls(validation_audio, wrap_predictions, network)
[wrap_score, wrap_details] = detection_performance(wrap_val_path, wrap_predictions, min_score=0.75);