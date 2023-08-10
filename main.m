%
% Vasco Sabino Pinto - vascopinto@tecnico.ulisboa.pt
%
clear
close all
clc

% Display the menu options
disp('-------------------------');
disp('Data:');
disp('1. Penn Table');
disp('2. Energy - Total');
disp('3. Energy - By sector');
disp('4. Exergy - Total');
disp('5. Exergy - By sector');
disp('-------------------------');

% Prompt the user to choose an option
choice = input('Select Data (1-5): ');

% Call the corresponding function based on the user's choice
switch choice
    case 1
        penn();
    case 2
        energy_total();
    case 3
        energy_sector();
    case 4
        exergy_total();        
    case 5
        exergy_sector();   
    otherwise
        disp('Invalid choice.');
end


% Information

if choice == 1
        % Define the table data
    tableData_penn = {
        'The vectors in the Matlab workspace correspond to the Penn Table variables.','';
        'Each line of the vector is the yearly value.','';
        '','';
        'For instance, ''avh'' is the average annual hours worked by persons engaged.', '';
        'The variable definition of each vector is in sheet ''Legend'' of the Penn Tabel excel.','';
        '','';
        'If Cobb-Douglas does not appear for a given country, either ''emp'', ''avh'', or ''hc'' are not determined in Penn Table.','';
};
    
    % Display the table
    disp('-------------------');
    for row = 1:size(tableData_penn, 1)
        fprintf('%s\t%s\n', tableData_penn{row, 1}, tableData_penn{row, 2});
    end
end

if choice == 2 || choice == 4
    
    % Define the table data
    tableData_total = {
        'Gross/Net   ', 'Includes Gross energy industry own Use. Remove the energy industry energy use for Net (option 3 and 5).';
        '','';
        'In the Matlab workspace, there are the following vectors:','';
        'E_f | X_f   ', 'Primary eNergy/eXergy in ktoe (Total). ';
        'E_p | X_p   ', 'Final eNergy/eXergy in ktoe (Total).';
        'E_u | X_u   ', 'Useful eNergy/eXergy in ktoe (Total).';
        'Units in ktoe. The number of columns corresponds to the number of years, thus yearly values.','';
     
};
    
    % Display the table
    disp('-------------------');
    for row = 1:size(tableData_total, 1)
        fprintf('%s\t%s\n', tableData_total{row, 1}, tableData_total{row, 2});
    end
    
end  
if choice == 3 || choice == 5
    
    % Define the table data
    tableData_sector = {
        'Gross/Net            ', 'Includes Gross energy industry own Use. Remove the energy industry energy use for Net.';
        '','';
        'In the Matlab workspace, you will find the energy vectors by sector.','';
        'Their syntax is:','';
        '   1. ''E_'' first letter is an E or X (Energy/Exergy)','';
        '   2. ''E_Residential'' then, the energy sector (e.g., Residential).','';
        '   3. ''E_Residential_Final'' finally, the conversion stage Final/Useful or the conversion efficiency between final and useful','';
        '','';
        'Thus, E_Residential_Final refers to the vector that stores the Final Energy of the Residential sector.','';
        'Units in ktoe. The number of columns corresponds to the number of years, thus yearly values.','';
    };
    % Display the table
    disp('-------------------');
    for row = 1:size(tableData_sector, 1)
        fprintf('%s\t%s\n', tableData_sector{row, 1}, tableData_sector{row, 2});
    end  
    
end