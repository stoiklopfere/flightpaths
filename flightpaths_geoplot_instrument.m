% Specify the base folder where your GPX files are located
baseFolder = 'C:\Users\nfischer\Documents\MATLAB\Flightpaths';

% Specify the subfolder name
subfolder = 'gpx';

% Construct the full path to the subfolder
subfolderPath = fullfile(baseFolder, subfolder);

% Define the string to search for
stringselect = '_GR_F230';

% List the FIFI files in the subfolder
gpxFiles = dir(fullfile(subfolderPath, ['*' stringselect '*.gpx']));  % Use stringselect
disp(gpxFiles);

% Determine the number of GPX files for colormap indexing
numFiles = sum(contains({gpxFiles.name}, stringselect));


% Define the colormap
cmap = hot;
cmap_mod = cmap(55:256, :);
%disp(cmap_mod)
% Initialize a colormap for flights
flightColormap = cmap(length(gpxFiles));

basemapUSGS1 = "basemapUSGS";
url = "https://basemap.nationalmap.gov/arcgis/rest/services/USGSImageryOnly/MapServer/tile/{z}/{y}/{x}";
addCustomBasemap(basemapUSGS1,url)
basemap1 = "usgsimagery";
mbtilesFilename1 = "usgsimagery.mbtiles";
addCustomBasemap(basemap1,mbtilesFilename1)


% Create a figure for plotting
figure;
% % Choose the basemap (e.g., 'streets', 'satellite', 'topographic', 'darkwater', etc.)
% basemapType = 'satellite';
% 
% % Set the basemap
% geobasemap(basemapType);


% Plot GPX paths with random colors, handling lines that cross the date line
for i = 1:length(gpxFiles)
    gpxFilePath = fullfile(subfolderPath, gpxFiles(i).name);
    gpxData = gpxread(gpxFilePath);
    
    % Filter GPX data based on the existence of "_FI_" in the file name
    if ~isempty(gpxData) && contains(gpxFiles(i).name, stringselect)
        % Generate a random index for the flight color
         randomIndex = randperm(size(cmap_mod, 1), 1);
         fprintf('Flight %d of %d\n', i, length(gpxFiles));
        
        % Use the randomly selected color for the flight
        flightColor = cmap_mod(randomIndex, :);
        disp(flightColor)

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
        for j = 1:length(lonSegments)
            % get rid of dateline issue
            if abs(lonSegments{j}) > 90
                disp(lonSegments{j})
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

% % Set the basemap to the desired type (e.g., 'satellite')
geobasemap(basemapUSGS1);




% Adjust the longitude limits to center the plot at 150°
% lonLimits = [-150, 0];
% latLimits = [-75, 75];
% geolimits(latLimits, lonLimits);

% Customize map appearance as needed
title('GREAT Flights');

% Save the figure as an image
% filename = 'output_map.png';  % Change the filename as needed
% saveas(gcf, filename, 'png');

% Close the figure
% close(gcf);
