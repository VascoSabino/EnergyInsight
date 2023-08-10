% File and sheet information
filename = 'pwt1001.xlsx';
sheet = 'Data';

% Read the data from Excel file as a table
dataPenn = readtable(filename, 'Sheet', sheet);

% Find the column index containing the 'countrycode' header
countryCodeColumnIndex = find(strcmp(dataPenn.Properties.VariableNames, 'countrycode'));
countryNamesColumnIndex = find(strcmp(dataPenn.Properties.VariableNames, 'country'));

% Extract the country codes from the specified column
countryCodes = string(dataPenn.countrycode);
countryNames = string(dataPenn.country);

% Handle missing country codes
missingIndices = ismissing(countryCodes);
countryCodes(missingIndices) = '';

uniqueCountriesCodes = unique(countryCodes,'stable');
uniqueCountriesNames = unique(countryNames,'stable');
countryYearColumnIndex = find(strcmp(dataPenn.Properties.VariableNames, 'year'));


% Display the menu
fprintf("Countries for analysis:\n");
for i = 1:length(uniqueCountriesNames)
    fprintf("%d. %s\n", i, uniqueCountriesNames{i});
end


% Get user input
selected = input(sprintf("Select country (1-%d): ", length(uniqueCountriesCodes)));
selectedCountries = uniqueCountriesCodes(selected);
selectedCountriesName = uniqueCountriesNames(selected);

% Display selected countries
fprintf("Selected country:\n");
disp(selectedCountriesName);

% Accessing the data for a specific country
% Replace 'CountryName' with the desired country name
desiredCountry = selectedCountries;
countryIndex = find(strcmp(uniqueCountriesCodes, desiredCountry));


%%
% Preallocate cell array to store country data
countryData = cell(size(uniqueCountriesCodes));

% Iterate over unique countries
for i = 1:numel(uniqueCountriesCodes)
    % Find the indices corresponding to the current country
    indices = find(countryCodes == uniqueCountriesCodes(i));
    
    % Extract the data for the current country
    countryData{i} = dataPenn(indices, countryYearColumnIndex:end);
end


if ~isempty(countryIndex)
    countryVariables = countryData{countryIndex};
end


% Assuming you have a table named 'dataTable'
% Get the column names
columnNames = countryVariables.Properties.VariableNames;

% Iterate over the column names
for i = 1:numel(columnNames)
    columnName = columnNames{i};
    
    % Get the column data as a vector
    columnData = table2array(countryVariables(:, columnName));
    
    % Assign the vector to a variable with the column name
    assignin('base', columnName, columnData);
   
end





%%
% Parameters
Y = rgdpe;
L = emp.*avh.*hc;
K = cn;

time = size(year,1);
Y_sim = zeros(time, 1);  % Economic output over time
Y_sim(1) = NaN;

% Simulate the model over time
for t = 2:time
    capsh(t) = 1-labsh(t);
    % Compute economic output using the production function
    Y_sim(t) = rtfpna(t) * K(t-1)^capsh(t) * L(t-1)^labsh(t);    
    
    TFP(t) = Y(t)./Y_sim(t);
end


% Plot the results
time = year(1):year(end);
figure;
plot(time, Y_sim/10^3, 'r--', 'LineWidth', 2);
hold on
plot(time, Y/10^3, 'b');
legend('Cobb-Douglas Y=K^k x L^L', 'Historical');
ylabel('Billion, 2017 USD');
title(sprintf('Real GDP - %s', selectedCountriesName));