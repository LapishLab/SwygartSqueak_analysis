function calls = uniform_call_labels(calls, labels)
arguments
    calls cell; % cell array of call tables
    labels {mustBeText}; % labels we are forcing the data to be
end
labels = string(labels);

for call_ind=1:numel(calls)
    c_table = calls{call_ind};
    
    if isempty(c_table)
        continue
    end

    % Convert existing labels to given labels if possible (keep as string arrays)
    types = string(c_table.Type);
    updated_types = strings(size(types));
    for label_ind=1:numel(labels)
        match = startsWith(types, labels(label_ind), IgnoreCase=true);
        updated_types(match) = labels(label_ind);
    end
    
    % Drop calls which do not match the given labels
    c_table.Type = updated_types;
    no_match = updated_types == "";
    c_table(no_match, :) = [];

    % format at categorical and make sure all labels are in metadata
    c_table.Type = categorical(c_table.Type);
    c_table.Type = addcats(c_table.Type, labels);


    % save back into cell array
    calls{call_ind} = c_table;
end
end