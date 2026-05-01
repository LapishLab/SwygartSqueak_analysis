function [calls, rejection_reason] = filter_calls(calls, opts)
    arguments
        calls table %
        opts.min_duration double = .005 % minimum duration of a USV to be included in the analysis
        opts.min_score double = 0.75 % Score (confidence) of a USV to be included in the analysis
        opts.include_rejected logical = false; % Should USVs marked as "rejected" be included in the analysis
        opts.min_freq double = 18; % minimum frequency allowed for box
        opts.max_freq double = 100; % maxiumum frequency allowed for box
        opts.include_non_usv logical = false; % Should calls with labels other than USV be included?
    end

    rejection_reason = strings(height(calls),1);
    if isempty(calls)
        return;
    end
    
    % perform various checks
    rejection_reason(calls.Box(:,3) < opts.min_duration) = "short";
    rejection_reason(calls.Score < opts.min_score) = "low score";
    rejection_reason(calls.Box(:,2) < opts.min_freq) = "low frequency";
    freq_max = calls.Box(:,2)+calls.Box(:,4);
    rejection_reason(freq_max > opts.max_freq) = "high frequency";


    % Only keep accepted calls
    if ~opts.include_rejected
        rejection_reason(calls.Accept~=1) = "Not marked accepted";
    end

    % Only keep calls labeled "USV
    if ~opts.include_non_usv
        rejection_reason(~startsWith(string(calls.Type), "USV")) = "Not labeled USV";
    end

    % Only return calls without rejection reasons
    calls = calls(strcmp(rejection_reason,""), :);
end