function output_table = batch_export_calls(predictions_folder, csv_path, output_folder, opts)
arguments
    predictions_folder {mustBeTextScalar}; % Path to directory containing detection files (1 per audio file)
    csv_path {mustBeTextScalar}; % Path CSV file keeping track of experimental variables and original data path (1 row per audio file)
    output_folder {mustBeTextScalar}; % Where to save combined session data (1 file and 1 row in csv for each session)
    opts.common_variables ={'subject','sex','treatment','issueTime', 'strain', 'scentDays'};
end

    %% Load per-audio-file table (from input csv file)
    t = readtable(csv_path, Delimiter=',');
    t = t(~cellfun(@isempty, t.split), :); % remove audio files not in test/validation/train

    [~,id,~] = fileparts(t.link_name); % Get ID from linkname % TODO: Save unique ID when first generating this table and use for all row references
    t.id = string(id);

    % Add prediction file paths to each row of table
    prediction_files = get_files_with_extension(predictions_folder, {'.mat'});
    for i=1:height(t)
        is_match = contains(prediction_files, t.id(i));
        if sum(is_match)>1
            error("More than 1 matching prediction file found for %s", t.id(i))
        elseif sum(is_match)==0
            warning("Can't find prediction file for %s", t.id(i))
        else
            t.prediction_path(i) = prediction_files(is_match);
        end
        
    end

    % Drop any rows with missing prediction files
    t(ismissing(t.prediction_path), :) = [];
    

    %% Prepare per-session table (save as export.csv)
    output_csv = fullfile(output_folder, "export.csv");
    output_table = table();
    output_table.session_path = unique(fileparts(t.audio_file_path));

    % Which variables from audio table should be carried into export table
    temp = cell(height(output_table),length(opts.common_variables));
    temp = cell2table(temp, "VariableNames",opts.common_variables);
    output_table = cat(2,output_table, temp);
    
    for i=1:height(output_table)
        % Find rows in audio table which correspond to this session
        session = output_table.session_path{i};
        in_session = contains(t.audio_file_path, session);

        common_vals = t(in_session,opts.common_variables);
        common_vals = unique(common_vals);
        
        if height(common_vals) > 1
            warning("More than 1 unique variable for session, skipping")
            continue
        end
        output_table{i, opts.common_variables} = table2cell(common_vals);


        % Merge these detection files and save at export mat
        output_table.export_path(i) = export_calls(t.prediction_path(in_session), output_folder);

        % Save the table of export info
        writetable(output_table, output_csv, Delimiter = ',');

        fprintf("Completed file %i/%i \n", i,height(output_table))
    end
end