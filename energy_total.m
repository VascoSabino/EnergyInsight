% File information
filename = 'eta_pfu_27_countries_E.csv';
filename_penn = 'pwt1001.xlsx'; % Optionally it can compare with Penn Table
sheet = 'Data';

% Read the data from CSV file as a cell array
data_E = readcell(filename, 'Delimiter', ',');
headerRow = data_E(1, :);

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
else
    % Determine the variable name based on the selected option
    variableName = '';
    if variableOption == 1
        variableName = 'IEA';
    elseif variableOption == 2
        variableName = 'MW';
    elseif variableOption == 3
        variableName = 'Both';
    end
    
    % Find the column index for the selected variable
    variableColumnIndex = find(strcmp(headerRow, 'IEAMW'));
    
    % Eliminate lines with undesired variable values
    variableValues = string(data_E(:, variableColumnIndex));
    undesiredIndices = ~strcmp(variableValues, variableName);
    data_E(undesiredIndices, :) = [];
    
    
    
    % Find the column index containing the 'Country' header
    countryColumnIndex = find(strcmp(headerRow, 'Country'));
    
    % Extract the country names from the specified column
    countries = string(data_E(2:end, countryColumnIndex));
    
    % Substitute 'CHNM' with 'CHN' in countries array(to match w/ Penn Table)
    countries = strrep(countries, 'CHNM', 'CHN');
    
    % Handle missing country names
    missingIndices = find(ismissing(countries));
    countries(missingIndices) = '';
    
    % Find the unique country names
    uniqueCountries = unique(countries,'stable');
    
    % Display the menu
    fprintf("Countries for analysis:\n");
    for i = 1:length(uniqueCountries)
        fprintf("%d. %s\n", i, uniqueCountries{i});
    end
    
    
    % Get user input
    selected = input(sprintf("Select country (1-%d): ", length(uniqueCountries)));
    selectedCountries = uniqueCountries(selected);
    
    
    % Accessing the data for a specific country
    % Replace 'CountryName' with the desired country name
    desiredCountry = selectedCountries;
    
    % Check if the user-specified country is in the unique country list
    if ~ismember(desiredCountry, uniqueCountries)
        disp('Country not found in the data.');
    else
        % Find the indices of the user-specified country
        countryIndices = find(countries == desiredCountry);
        if desiredCountry ~= uniqueCountries(1)
            countryIndices = countryIndices(2:end);
            countryIndices = [countryIndices; countryIndices(end)+1];
        else
            countryIndices = [countryIndices; countryIndices(end)];
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
        
        
        % Define the years vector
        yearsIndex = find(strcmp(headerRow, 'Year'));
        for i=1:length(countryIndices)
            years_energy(i) = data_E{countryIndices(i),yearsIndex};
        end
        
        % Find the column indices for the variables of interest
        E_pIndex = find(strcmp(headerRow, 'EX.p'));
        E_fIndex = find(strcmp(headerRow, 'EX.f'));
        E_uIndex = find(strcmp(headerRow, 'EX.u'));
        eta_pfIndex = find(strcmp(headerRow, 'eta_pf'));
        eta_fuIndex = find(strcmp(headerRow, 'eta_fu'));
        eta_puIndex = find(strcmp(headerRow, 'eta_pu'));
        
        % Extract the vectors for the selected country
        for i=1:length(countryIndices)
            E_p(i,:) = data_E{countryIndices(i),E_pIndex};
            E_f(i,:) = data_E{countryIndices(i),E_fIndex};
            E_u(i,:) = data_E{countryIndices(i),E_uIndex};
            E_eta_pf(i,:) = data_E{countryIndices(i),eta_pfIndex};
            E_eta_fu(i,:) = data_E{countryIndices(i),eta_fuIndex};
            E_eta_pu(i,:) = data_E{countryIndices(i),eta_puIndex};
        end
    end
end




% Read the data from Excel file as a table
dataPenn = readtable(filename_penn, 'Sheet', sheet);

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


% Accessing the data for a specific country
% Replace 'CountryName' with the desired country name
countryIndex = find(strcmp(uniqueCountriesCodes, desiredCountry));

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
    
    % Extract the last elements, since the penn table starts in 1950 and
    % the energy tables in 1960, in order to have the same vector size
    columnData = columnData(11:end);
    
    % Assign the vector to a variable with the column name
    assignin('base', columnName, columnData);
    
end







%% Plot Energy and Efficiencies individually
% Create a new figure
figure;

% Plot Primary Energy
plot(years_energy, E_p);
hold on;

% Plot Final Energy
plot(years_energy, E_f);
hold on;

% Plot Useful Energy
plot(years_energy, E_u);

% Set the axis labels and title
title(sprintf('Energy - %s', desiredCountry));
ylabel('[ktoe]');

% Set the y-axis limits
ylim([0, 1.1 * max([E_p; E_f; E_u])]);

% Set the y-axis tick intervals
yticks(0:(max([E_p; E_f; E_u]) - 0.9 * min([E_p; E_f; E_u])) / 10:1.1 * max([E_p; E_f; E_u]));

% Add a legend
legend('Primary', 'Final', 'Useful');


% Create a new figure
figure;
% Plot Primary-to-Final efficiency
plot(years_energy, E_eta_pf);
hold on;
% Plot Final-to-Useful efficiency
plot(years_energy, E_eta_fu);
hold on;
% Plot Primary-to-Useful efficiency
plot(years_energy, E_eta_pu);
hold off;

% Set the title
title(sprintf('Energy Efficiency - %s', desiredCountry));
% Create a legend
legend('Primary-to-Final', 'Final-to-Useful', 'Primary-to-Useful');
ylim([0, 1]);


%% Now, all of them individually
figure;
% Plot Primary Energy
h1 = subplot(1, 3, 1);
plot(years_energy, E_p);
subtitle('Primary Energy (Total)');
ylabel('[ktoe]');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 0.5]);

% Plot Final Energy
h2 = subplot(1, 3, 2);
plot(years_energy, E_f);
title(sprintf('Energy - %s', desiredCountry));
subtitle('Final Energy (Total)');
ylabel('[ktoe]');

% Plot Useful Energy
h3 = subplot(1, 3, 3);
plot(years_energy, E_u);
subtitle('Useful Energy (Total)');
ylabel('[ktoe]');





%Create a new figure
figure;

%Plot Primary-to-Final efficiency
subplot(1, 3, 1);
plot(years_energy, E_eta_pf);
subtitle('Primary-to-Final (Total)');
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 0.5]);

%Plot Final-to-Useful efficiency
subplot(1, 3, 2);
plot(years_energy, E_eta_fu);
title(sprintf('Energy Efficiency - %s', desiredCountry));
subtitle('Final-to-Useful (Total)');

%Plot Primary-to-Useful efficiency
subplot(1, 3, 3);
plot(years_energy, E_eta_pu);
subtitle('Primary-to-Useful (Total)');




% Create a new figure
figure;
% in case exergy database and penn table end in different years, the plot
% will only show the years that both databases have
max_size = min(length(year),length(years_energy));

years_energy=years_energy(1:max_size);
rgdpo=rgdpo(1:max_size); rgdpe=rgdpe(1:max_size);
E_p=E_p(1:max_size);
E_f=E_f(1:max_size);
E_u=E_u(1:max_size);


% Plot Primary Exergy
plot(years_energy, E_p*10^3./rgdpo);
hold on;

% Plot Final Exergy
plot(years_energy, E_f*10^3./rgdpo);
hold on;

% Plot Useful Exergy
plot(years_energy, E_u*10^3./rgdpo);

% Set the axis labels and title
title(sprintf('Energy/GDP - %s', desiredCountry));
ylabel('toe/M€2017');

% Add a legend
legend('Primary Energy/GDP', 'Final Energy/GDP', 'Useful Energy/GDP');