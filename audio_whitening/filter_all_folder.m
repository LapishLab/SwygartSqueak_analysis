function filter_all_folder(audio_folder, opt)
arguments
    audio_folder {mustBeTextScalar} % path to folder containing audio
    opt.output_folder {mustBeTextScalar} % path to save audio to (defaults to "whitened" subfolder in audio_folder)
    opt.save_format {mustBeTextScalar} = ".flac" % Format of whitened audio
    opt.audio_extension {mustBeText} = [".wav", ".mp3", ".flac", ".m4a", ".ogg"] 
end
if ~isfield(opt, 'output_folder')
    opt.output_folder = fullfile(audio_folder, "whitened");
end

% Get list of audio files
file_names = string({dir(audio_folder).name});
file_names(~endsWith(file_names, opt.audio_extension, 'IgnoreCase', true)) = [];
if isempty(file_names)
    error("No audio files found in %s", audio_folder)
end

% Create output directory if necessary
if ~exist(opt.output_folder, 'dir')
    mkdir(opt.output_folder);
end

% Loop over audio files
audio_path = fullfile(audio_folder, file_names);
[~,basename,~] = fileparts(audio_path);
output_path = fullfile(opt.output_folder, basename + opt.save_format);
for i=1:length(audio_path)
    fprintf("Whitening %i/%i \n", i, length(audio_path))
    whiten_and_resave(audio_path(i),output_path(i))
end

end
