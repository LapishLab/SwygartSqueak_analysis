function whiten_and_resave(wav,new_name)
[original_audio, fs] = audioread(wav); % Read the original audio file

frac = 0.1;
fprintf('Getting background \n')
background = get_background(original_audio, fs, frac);
resample_rate = 25;
fprintf('Generating filter \n')
filter = gen_filter(background, fs, resample_rate); % generate filter
fprintf('Applying filter \n')
audio_out = apply_filter(original_audio, filter);

%normalize audio
audio_out = audio_out/50;
audio_out(audio_out>1)=1;
audio_out(audio_out<-1)=-1;

% figure(1);
% subplot(1,2,1)
% plot_spectrum_data(original_audio(1:fs),fs)
% subplot(1,2,2)
% plot_spectrum_data(audio_out(1:fs),fs)

%% get audio metadata
info = audioinfo(wav);
comment = sprintf(['%s\nSpectrally whitened using inverse power spectra' ...
    ' on %s'], info.Comment, string(datetime('now')));
%% save audio

fprintf('Saving Audio \n')
audiowrite(new_name, audio_out, fs, Comment=comment, Artist=info.Artist);

end