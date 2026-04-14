function file_paths = get_files_with_extension(folder, extensions)
    all_files = struct2table(dir(fullfile(folder)));
    [~, ~, file_exts] = cellfun(@fileparts, all_files.name, 'UniformOutput', false);
    is_match = ismember(lower(file_exts), extensions);
    file_paths = fullfile(folder, all_files.name(is_match));
end