filename = 'eta_fu_sector_27_countries_E.csv';

% Read the data from the CSV file
data_Esector = readcell(filename, 'Delimiter', ',');
headerRow = data_Esector(1, :);

% Prompt the user to select the Database to analyze
disp('-------------------------');
disp('Database:');
disp('1. IEA – International Energy Agency');
disp('2. MW - Muscle work');
disp('3. Both (IEA + MW)');
variableOption = input('Select database (1-3): ');

% Validate the variable option
if variableOption < 1 || variableOption > 3
    disp('Invalid.');
    return;
end

% Determine the variable name based on the selected option
variableNames = {'IEA', 'MW', 'Both'};
variableName = variableNames{variableOption};

% Find the column index for the selected variable
variableColumnIndex = find(strcmp(headerRow, 'IEAMW'));

% Eliminate lines with undesired variable values
variableValues = string(data_Esector(:, variableColumnIndex));
undesiredIndices = ~strcmp(variableValues, variableName);
data_Esector(undesiredIndices, :) = [];

% Find the column index containing the 'Country' header
countryColumnIndex = find(strcmp(headerRow, 'Country'));

% Extract the country names from the specified column
countries = string(data_Esector(2:end, countryColumnIndex));

% Substitute 'CHNM' with 'CHN' in countries array(to match w/ Penn Table)
countries = strrep(countries, 'CHNM', 'CHN');

% Handle missing country names
missingIndices = ismissing(countries);
countries(missingIndices) = '';

% Find the unique country names and display the menu
uniqueCountries = unique(countries,'stable');
fprintf("Countries for analysis:\n");
for i = 1:length(uniqueCountries)
    fprintf("%d. %s\n", i, uniqueCountries{i});
end

% Get user input
selected = input(sprintf("Select country (1-%d): ", length(uniqueCountries)));
selectedCountry = uniqueCountries(selected);
desiredCountry = selectedCountry;

% Check if the user-specified country is in the unique country list
if ~ismember(selectedCountry, uniqueCountries)
    disp('Country not found in the data.');
    return;
end

% Find the indices of the user-specified country
countryIndices = find(countries == selectedCountry);
if selectedCountry ~= uniqueCountries(1)
    countryIndices = countryIndices(2:end);
    countryIndices = [countryIndices; countryIndices(end)+1];
else
    countryIndices = [countryIndices; countryIndices(end)+1];
end

% Initialize variables to store the initial and final indices
Indices = [];

% Analyze the country indices
numIndices = length(countryIndices);
for i = 1:numIndices
    % Check if the index is the first or last index
    if i == 1 || i == numIndices
        Indices = [Indices countryIndices(i)+1];
    else
        % Check if the country name changes
        if countryIndices(i) ~= countryIndices(i-1) + 1
            Indices = [Indices countryIndices(i)];
        end
    end
end

% Add the last index if it is not included
if Indices(end) ~= countryIndices(end)
    Indices = [Indices countryIndices(end)];
end


% Find the column index containing the 'Sector' header
sectorColumnIndex = find(strcmp(headerRow, 'Sector'));

% Extract the sectors based on country indices
sectors = string(data_Esector(:, sectorColumnIndex));
% To prevent any sintax mistakes substitute . , / - ( ) for blank spaces
sectors = strrep(sectors, ' ', '');
sectors = strrep(sectors, '.', '');
sectors = strrep(sectors, ',', '');
sectors = strrep(sectors, 'ç', 'c');
sectors = strrep(sectors, '/', '');
sectors = strrep(sectors, '-', '');
sectors = strrep(sectors, '(', '');
sectors = strrep(sectors, ')', '');
selectedSectors = sectors(countryIndices);

% Find the column index containing the 'var' header
varColumnIndex = find(strcmp(headerRow, 'var'));

% Define the years vector
years = headerRow(varColumnIndex+1:end);
% years = strrep(years, 'X', '');
% years = strrep(years, 'E', '');
years = cell2mat(years);

% The 'var' header refers to the conversion stages of energy
stages = string(data_Esector(:, varColumnIndex));
selectedStages = stages(countryIndices);

% Find the column indices to the right of the 'var' column
columnIndices = varColumnIndex + 1:size(data_Esector, 2);

% Create new variables based on the sectors and conversion stages
for i = 1:length(selectedSectors)
    if selectedCountry == uniqueCountries(1)
        variableName = ['E_' char(selectedSectors(i)) '_' char(selectedStages(i))];
        variableData = data_Esector(i, varColumnIndex+1:end);
    else
        variableName = ['E_' char(selectedSectors(i)) '_' char(selectedStages(i))];
        variableData = data_Esector(i-2+min(Indices), varColumnIndex+1:end);
    end
    % Convert numeric cells to double and retain non-numeric cells as they are
    variableData = cellfun(@(x) isnumeric(x)*x, variableData, 'UniformOutput', false);
    
    % Replace empty cells with 0
    variableData(cellfun(@isempty, variableData)) = {0};
    
    % Replace vectors [0,0] with 0
    variableData(cellfun(@(x) isequal(x, [0,0]), variableData)) = {0};
    
    % Convert cell array to normal array
    variableData = cell2mat(variableData);
    
    % Replace NaN values with 0
    variableData(isnan(variableData)) = 0;
    
    % Assign the variable name to the workspace
    assignin('base', variableName, variableData);
end





%% BAR + PIE CHART Final Energy

% Relative weight (%) of the sector. If more than the defined % value, it is
% shown in the legend (to avoid having too much legend entries)
Sector_minWeight = 0.05;

% Find all the sectors ending in 'Final'
E_vectorsname_Final = who('*_Final');
numSectors = numel(E_vectorsname_Final);

% Initialize the integer 'total final energy from all years'
EtotalFinal = 0;
EsectorFinal = zeros(numSectors, length(years));
legendNamesFinal = cell(numSectors, 1);
legendNamesFinal(:) = {''};

% Calculate the total final energy for each sector and create stacked bar plot
for i = 1:numSectors
    EsectorFinal(i, :) = eval(E_vectorsname_Final{i});
    EtotalFinal = EtotalFinal + sum(EsectorFinal(i, :));
end


figure;
hBarFinal = bar(years, EsectorFinal, 'stacked');
numSectors = size(EsectorFinal, 1);
colorsFinal = colorcube(numSectors*3);  % Define a colormap with the same number of colors as segmentsnumSegmentsFinal = size(XsectorFinal, 2);

% Create legend labels and set bar colors

for j = 1:numSectors
    if sum(EsectorFinal(j, :)) >= Sector_minWeight * EtotalFinal
        cleanName = strrep(E_vectorsname_Final{j}, 'E_', '');
        cleanName = strrep(cleanName, '_Final', '');
        legendNamesFinal{j} = cleanName;
    end
    set(hBarFinal(j), 'FaceColor', colorsFinal(j, :));
end

title('Final energy by sector - ' + desiredCountry);
ylabel('[ktoe]');
legend(legendNamesFinal);
text(0.01, 0.96, sprintf('Only sectors with a weight >= %d%% are in the legend.\nTo change that, adjust SectorminWeight.', Sector_minWeight*100), 'Units', 'normalized');





% Create pie chart
sectorTotalFinal = sum(EsectorFinal, 2);
figure;
hPieFinal = pie(sectorTotalFinal, legendNamesFinal);
title(sprintf('Final energy by sector (%d-%d) - %s', min(years), max(years), desiredCountry));

% Set pie chart colors and labels
hPatchesFinal = findobj(hPieFinal, 'Type', 'Patch');
colorsFinal = colorsFinal(1:numSectors, :);
for i = 1:numSectors
    hPatchesFinal(i).FaceColor = colorsFinal(i, :);
end

percentageValuesFinal = 100 * sectorTotalFinal / EtotalFinal;
legendLabelsFinal = cell(numSectors, 1);
hTextFinal = findobj(hPieFinal, 'Type', 'text');
for i = 1:numSectors
    if sum(EsectorFinal(i, :)) >= Sector_minWeight * EtotalFinal
        legendLabelsFinal{i} = sprintf('%s\n%.1f%%', legendNamesFinal{i}, percentageValuesFinal(i));
        hTextFinal(i).String = legendLabelsFinal{i};
    else
        legendLabelsFinal{i} = legendNamesFinal{i};
    end
end
legend(legendNamesFinal);



%% BAR + PIE CHART Useful Energy
% Find all the sectors ending in '_Useful'
E_vectorsname_Useful = who('*_Useful');
numSectors = numel(E_vectorsname_Useful);

% Initialize the integer 'total useful energy from all years'
EtotalUseful = 0;
EsectorUseful = zeros(numSectors, length(years));
legendNamesUseful = cell(numSectors, 1);
legendNamesUseful(:) = {''};

% Calculate the total useful energy for each sector and create stacked bar plot
for i = 1:numSectors
    EsectorUseful(i, :) = eval(E_vectorsname_Useful{i});
    EtotalUseful = EtotalUseful + sum(EsectorUseful(i, :));
end



figure;
hBarUseful = bar(years, EsectorUseful, 'stacked');
numSectors = size(EsectorUseful, 1);
colorsUseful = colorcube(numSectors*3);  % Define a colormap with the same number of colors as segments

% Create legend labels and set bar colors
for j = 1:numSectors
    if sum(EsectorUseful(j, :)) >= Sector_minWeight * EtotalUseful
        cleanName = strrep(E_vectorsname_Useful{j}, 'E_', '');
        cleanName = strrep(cleanName, '_Useful', '');
        legendNamesUseful{j} = cleanName;
    end
    set(hBarUseful(j), 'FaceColor', colorsUseful(j, :));
end

title('Useful energy by sector - ' + desiredCountry);
ylabel('[ktoe]');
legend(legendNamesUseful);
text(0.01, 0.96, sprintf('Only sectors with a weight >= %d%% are in the legend.\nTo change that, adjust SectorminWeight.', Sector_minWeight*100), 'Units', 'normalized');






% Create pie chart
sectorTotalUseful = sum(EsectorUseful, 2);
figure;
hPieUseful = pie(sectorTotalUseful, legendNamesUseful);
title(sprintf('Useful energy by sector (%d-%d) - %s', min(years), max(years), desiredCountry));

% Set pie chart colors and labels
hPatchesUseful = findobj(hPieUseful, 'Type', 'Patch');
colorsUseful = colorsUseful(1:numSectors, :);
for i = 1:numSectors
    hPatchesUseful(i).FaceColor = colorsUseful(i, :);
end

percentageValuesUseful = 100 * sectorTotalUseful / EtotalUseful;
legendLabelsUseful = cell(numSectors, 1);
hTextUseful = findobj(hPieUseful, 'Type', 'text');
for i = 1:numSectors
    if sum(EsectorUseful(i, :)) >= Sector_minWeight * EtotalUseful
        legendLabelsUseful{i} = sprintf('%s\n%.1f%%', legendNamesUseful{i}, percentageValuesUseful(i));
        hTextUseful(i).String = legendLabelsUseful{i};
    else
        legendLabelsUseful{i} = legendNamesUseful{i};
    end
end
legend(legendNamesUseful);