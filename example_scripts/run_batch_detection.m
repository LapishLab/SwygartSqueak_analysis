
audio_root = "/home/lapishla/Documents/GitHub/DeepSqueak-Network-Performance/detection/human_curated/scentEtOH_urgencyDD/audio/";
train_audio = audio_root + "train/";
test_audio = audio_root + "test/";
val_audio = audio_root + "validation/";

output_folder = "/home/lapishla/Desktop/net_predictions_scentEtOH_urgencyDD/";

network = load("/home/lapishla/Documents/GitHub/DeepSqueak/Networks/YOLOX3_2026-03-03_09-31-34.mat");


batch_detect_calls(train_audio, output_folder, network)
batch_detect_calls(test_audio, output_folder, network)
batch_detect_calls(val_audio, output_folder, network)