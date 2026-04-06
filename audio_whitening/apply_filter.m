function audio_out = apply_filter(audio_in, filter)
    chunk_target = 250e3*60*5; % Chunks audio into ~5 minute bins (assuming 250kHz)
    num_chunks = ceil(length(audio_in) / chunk_target);
    audio_out = nan(size(audio_in));
    
    for i = 1:num_chunks
        start_idx = (i-1) * chunk_target + 1;
        end_idx = min(i * chunk_target, length(audio_in));
        audio_out(start_idx:end_idx) = filter_chunk(audio_in(start_idx:end_idx), filter);
    end
end

function audio_out = filter_chunk(audio_in, filter)
    %% take fft of whole audio
    X = fftshift(fft(audio_in)); % fftshift so that 0 frequency in middle
    
    %% upsample filter to match fft and apply
    little_x = linspace(0,1, length(filter));
    bix_x = linspace(0,1, length(X));
    big_filter = interp1(little_x, filter,bix_x, "linear");
    Y = X(:) .* big_filter(:); % Apply filter in frequency domain
    
    %% invert filtered fft back to time domain and normalize
    audio_out = real(ifft(fftshift(Y)));
end