% Specify the base folder where your GPX files are located
baseFolder = 'C:\Users\nfischer\Documents\MATLAB\Flightpaths';

% Specify the subfolder name
subfolder = 'gpx';

% Construct the full path to the subfolder
subfolderPath = fullfile(baseFolder, subfolder);

% Get the flight numbers from text file
% The Flight Numbers in the Text file MUST have three digits, but it
% doesn't matter if it is something like F345 or FLT345.
inputFile = 'Steve.txt';

% Extract flight numbers
flightNumbers = extractFlightNumbers(inputFile);
disp(flightNumbers);



% List the GPX files in the subfolder
gpxFiles = dir(subfolderPath);
gpxFiles = gpxFiles(~[gpxFiles.isdir]);  % Remove directories from the list

% Filter files based on the flightNumbers
selectedFiles = [];
pattern = '(?<!\d)(\d{3})(?!\d)';
for i = 1:length(gpxFiles)
    fileName = gpxFiles(i).name;
    % Check if the file name contains any flight number
    if any(ismember(flightNumbers, str2double(regexp(fileName, pattern, 'match'))))
        selectedFiles = [selectedFiles; gpxFiles(i)];
    end
end
disp(selectedFiles)
% Assuming selectedFiles is a struct array with a field 'name'
% flightNumbers is an array with three-digit numbers

% Extract the three-digit numbers from the 'name' field of selectedFiles
extractedNumbersCell = cellfun(@(x) str2double(regexp(x, '\d+', 'match')), {selectedFiles.name}, 'UniformOutput', false);

% Concatenate the non-empty arrays into a single array
extractedNumbers = cell2mat(extractedNumbersCell(~cellfun(@isempty, extractedNumbersCell)));

% Identify flightNumbers without a corresponding entry in extractedNumbers
missingNumbers = setdiff(flightNumbers, extractedNumbers);

% Define the colormap
cmap = hot;
% Get rid of some rows to eliminate dark colors in front of dark ocean
cmap_mod = cmap(55:256, :);

% nice background basemap  
basemapUSGS1 = "basemapUSGS";
url = "https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}";
addCustomBasemap(basemapUSGS1,url)
basemap1 = "usgsimagery";
mbtilesFilename1 = "usgsimagery.mbtiles";
addCustomBasemap(basemap1,mbtilesFilename1)


% Create a figure for plotting
figure;



% Plot GPX paths with random colors, handling lines that cross the date line
for i = 1:length(selectedFiles)
    gpxFilePath = fullfile(subfolderPath, selectedFiles(i).name);
    gpxData = gpxread(gpxFilePath);
    
    % Filter GPX data based on the value in the array
    if ~isempty(gpxData) 
        % Generate a random index for the flight color
        randomIndex = randperm(size(cmap_mod, 1), 1);
        
        % Use the randomly selected color for the flight
        flightColor = cmap_mod(randomIndex, :);
        disp(flightColor)
        fprintf('Flight %d of %d\n', i, length(selectedFiles));

        % Initialize arrays to store segment data
        latSegments = {};
        lonSegments = {};

        % Initialize the first segment
        latSegments{1} = [];
        lonSegments{1} = [];

        for j = 2:length(gpxData.Longitude)
            % Check if the difference in longitude crosses the date line
            if abs(gpxData.Longitude(j) - gpxData.Longitude(j - 1)) > 180
                % Start a new segment if the path crosses the date line
                latSegments{end + 1} = [];
                lonSegments{end + 1} = [];
            end

            % Add data to the current segment
            latSegments{end} = [latSegments{end}, gpxData.Latitude(j)];
            lonSegments{end} = [lonSegments{end}, gpxData.Longitude(j)];
        end


        % Plot each segment using geoplot with a randomly selected color
        for j = 1:length(latSegments)
            % get rid of dateline issue
            if lonSegments{j} > 50
                lonSegments{j} = lonSegments{j} -360;
                
            end
        
%             % Adjust the longitude limits to center the plot at 150°
% %             lonLimits = [centerLongitude - 180, centerLongitude + 180];
%             lonLimits = [-150, 0];
%             latLimits = [-75, 75];
%             geolimits([min(latSegments{j}) max(latSegments{j})], lonLimits);
            
            % Plot the segment with the random color
            geoplot(latSegments{j}, lonSegments{j}, 'Color', flightColor, 'LineWidth', 1);
            hold on;
        end
    end
end

% Set the basemap to the desired type (e.g., 'satellite')
geobasemap(basemapUSGS1);

% Adjust the longitude limits to center the plot at 150°
% lonLimits = [centerLongitude - 180, centerLongitude + 180];
lonLimits = [-150, 0];
latLimits = [-75, 75];
geolimits(latLimits, lonLimits);

% Customize map appearance as needed
% Extract the name of the text file without the extension
[~, fileName, ~] = fileparts(inputFile);
title(['Flights for ' fileName]);
%title('FIFI-LS Flights');

% Save the figure as an image
% filename = 'output_map.png';  % Change the filename as needed
% saveas(gcf, filename, 'png');

% Close the figure
% close(gcf);


% Display flight numbers for which no struct name was found
disp('Flight numbers for which no flight data was found:');
disp(missingNumbers);


