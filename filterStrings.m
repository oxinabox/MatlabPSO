function [ filtered ] = filterStrings( strings, removeSubstring )
%FILTERSTRINGS returns all the string input except thos containing the
%removeSubstring
    keep = cellfun(@isempty, strfind(strings, removeSubstring));
    filtered = strings(keep);


end

