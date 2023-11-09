% Function to extract flight numbers using regular expressions
function flightNumbers = extractFlightNumbers(inputFile)
    % Use regular expression to find all three-digit numbers
    % This means match 3 digits that are NOT followed and preceded by a digit.

    % Read input file content
    fileContent = fileread(inputFile);
    pattern = '(?<!\d)(\d{3})(?!\d)';
    matches = regexp(fileContent, pattern, 'match');
    flightNumbers = cellfun(@(x) str2double(x), matches);
end