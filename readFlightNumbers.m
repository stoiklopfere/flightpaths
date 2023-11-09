% The Flight Numbers in the Text file MUST have three digits, but it
% doesn't matter if it is something like F345 or FLT345.


inputFile = 'Nadine.txt';
outputFilePath = 'Nadine_Flights.txt';


% Extract flight numbers
flightNumbers = extractFlightNumbers(inputFile);
disp(flightNumbers);
whos flightNumbers

