function plot_box_instance(target_box, other_boxes, audio_file, target_label, other_label)

% add callback function to change color limit with scroll wheel
h = figure(1); clf;
h.WindowScrollWheelFcn = @scrollWheelClimCallback;

%
mid_time = target_box(1) + target_box(3)/2;
window_size = 0.5;
time_range = [mid_time-window_size/2, mid_time+window_size/2];

%add check to set time_range(1) if it is negative. Means that the call is
%extending beyond the start of the file which is impossible so set it to 0
%in this case
if time_range(1) < 0
    time_range(1) = 0;
end 

plot_spectrum(audio_file, time_range(1), time_range(2));
plot_boxes(target_box, 'green', target_label)

% TODO: restrict other boxes to within this window
plot_boxes(other_boxes, 'blue', other_label)

[~,filename,~] = fileparts(audio_file);
title(strrep(filename, '_', '\_'))

input("hit enter to continue to next USV \n", "s");
end

function plot_boxes(boxes, color,label)
    for i=1:height(boxes)
        rectangle('pos', boxes(i,:), EdgeColor=color)
        
        text(boxes(i,1),boxes(i,2), label(i), Color=color, VerticalAlignment="top")

    end
end

function scrollWheelClimCallback(src, event)
    gain = 1+event.VerticalScrollCount*.1;
    ax = gca(src);
    ax.CLim = [ax.CLim(1), ax.CLim(2)*gain];
end