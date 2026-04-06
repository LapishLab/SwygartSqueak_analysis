function filter_all_csv(csvPath)
    % Validate input
    if ~isfile(csvPath)
        error('CSV file not found: %s', csvPath);
    end

    % Read CSV into a table
    T = readtable(csvPath, Delimiter=",");
    
    % save location for whitened audio data. Saved in folder on computer
    % that also has the links to the audio
    [folder,name,~]=fileparts(T.link_name);
    new_names = fullfile(folder,name+"_whitened.flac");

    for i = 1:height(T)
        audioFile = T.link_name{i};
        if isempty(audioFile)
            fprintf('No entry for link_name for row %i, skipping\n', i)
            continue
        end
        if ~isfile(audioFile)
            warning('Invalid audio path at row %d: %s \n', i, audioFile);
            continue
        end

        if exist(new_names(i),'file')
            fprintf('File already exists, skipping: %s  \n', new_names(i))
        else
            fprintf('Whitening: %s \n', audioFile)
            T.whitened_path{i} = new_names(i);
            whiten_and_resave(audioFile, new_names(i));
            fprintf('Completed %i/%i: Re-saving %s \n', i, height(T), csvPath)
            T.whitened_path{i} = new_names(i);
            writetable(T,csvPath)
        end
    end
end