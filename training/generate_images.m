function generate_images(audioFile, calls, output_dir, settings, opts)
arguments
    audioFile
    calls
    output_dir
    settings
    opts.plot logical = false
    opts.saveAnnotated logical = false;
end

[audio,Fs] = audioread(audioFile);
img_dur = settings.img_dur;
audio_dur = length(audio)/Fs;

% Only use images that contain calls
image_start = 0:img_dur*(1-settings.img_overlap):audio_dur-img_dur; % in seconds
image_stop = image_start + img_dur;

call_start = calls.Box(:,1);
call_width = calls.Box(:,3);
call_stop = call_start + call_width;

call_freq = calls.Box(:,2) * 1000;
call_height = calls.Box(:,4) * 1000;

has_calls = any(call_start>image_start & call_stop<image_stop);
image_start = image_start(has_calls);


[~,~] = mkdir(output_dir);

vars = {'imageFilename', 'Boxes', 'Labels'};
varTypes = {'string', 'cell', 'cell'};
image_table = table('Size', [length(image_start), length(vars)], 'VariableNames', vars, 'VariableTypes', varTypes);

for b = 1:length(image_start)
    %% generate spectrogram of audio segment
    start_ind = round(image_start(b)*Fs)+1; % add 1 because index by 1 instead of 0
    stop_ind = start_ind + round(img_dur*Fs)-1;
    [im, T, F] = gen_spect_image(audio(start_ind:stop_ind), Fs, settings);
    T = T + image_start(b);

    %% Get boxes fully contained in image
    in_img = call_start > T(1) & call_stop < T(end);

    boxes = nan(sum(in_img), 4);

    boxes(:,1) = (call_start(in_img)-T(1)) / (T(2)-T(1));
    boxes(:,3) = call_width(in_img) / (T(2)-T(1));

    boxes(:,2) = (call_freq(in_img)-F(1)) / (F(2)-F(1));
    boxes(:,4) = call_height(in_img) / (F(2)-F(1));

    % TODO: Blacken start and end of image if overlapping with cal
    % on_start_edge = call_start<T(1) & call_stop>T(end);

    %% Plot
    if opts.plot
        figure(1); clf; hold on
        imshow(im);
        axis on;
        xlim([0 width(im)]+0.5)
        ylim([0 height(im)]+0.5)
        for r=1:height(boxes)
            rectangle('Position',boxes(r,:), 'EdgeColor',   'b')
        end
        pause(.1)
    end
    if opts.saveAnnotated
    im = insertObjectAnnotation(im, "Rectangle", boxes, ...
        calls.Type(in_img));
    end

    %% Save image file and add entry to table
    filename = fullfile(output_dir, sprintf('%d.png', b));
    imwrite(im, filename, 'BitDepth', 8)   

    image_table.imageFilename(b)= filename;
    image_table.Boxes(b) = {boxes};
    image_table.Labels(b) = {calls.Type(in_img)};
end

% Save the file table
fname = fullfile(output_dir, "image_info.mat");
save(fname, "image_table", "settings")
end