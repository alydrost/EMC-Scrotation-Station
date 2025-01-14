function [folderName, axes, refDist, analysisTypes, dataDir, ...
protOrder, protNames, colors, linestyles] = experimentInformation()

    useTemplate = questdlg("Load fields from template csv/excel file?");
    switch useTemplate
        case 'Yes'; [file, path] = uigetfile("*.csv;*.xlsx", ...
                "Choose Analysis Template", "Templates");
        case 'No'; [file, path] = deal("Sample Analysis Template.xlsx", pwd);
        otherwise; file = 0;
    end
    if file + "" == "0"; fprintf("Analysis Canceled\n"); return
    else; fprintf("Reading template file: " + file + "\n");
        template = readtable(fullfile(path, file)); end
    
    format shortg;
    userInput = inputdlg('All analysis files will be organized into a folder with this name:', ...
        'Analysis Folder Name', [1 60], template{1,1});
    
    time = floor(clock);
    folderName = userInput + "[" + date + ", " + time(4) + "-" + time(5) + "]";
    dupNum = 1;
    if exist(folderName, 'dir')
        while exist(folderName + "(" + dupNum + ")", 'dir'); dupNum = dupNum + 1; end
        folderName = folderName + "(" + dupNum + ")";
    end
    
    analysisTypes = ["Linear", "Log", "Distance", "Absolute Value"];
    include = inputdlg([sprintf("Enter 0 to include and 0 to exclude analysis:\n\n" + analysisTypes(1)), analysisTypes(2:end)], ...
        'Analysis Types', [1 60], ismember(analysisTypes, template{:,2}) + 0 + "");
    analysisTypes = analysisTypes(ismember(include, '1'));
    
    axes = inputdlg(["Enter y axis label", "Enter label for " + analysisTypes + " Analysis"], ...
        'Axes Names', [1 60], [template{:,3}; repmat({''},4,1)]);
    
    refDist = inputdlg('Enter expected location of kink:', ...
        'Kink Location', [1 60], template{1,6} + "");
    
    dataDir = uigetdir(fullfile(fileparts(pwd), 'Data'), "Choose Group Data Folder that contains Protocols");
    dataDir = dir(dataDir);
    if dataDir(3).name + "" == ".DS_Store"
        dataDir = dataDir([1,2,4:end]);
    end
    protNames = {dataDir(3:end).name};
    order = template{:, 8};
    message = sprintf("Found " + length(protNames) + " protocols. " + ...
        "Choose their order in legend (0 to exclude):\n\n" + protNames(1));
    protOrder = str2double(inputdlg({message, protNames{2:end}}, "Plotting Order", [1 60], order + ""));
    
    newTemplate = cell2table(cell(0,width(template)), 'VariableNames', template.Properties.VariableNames);
    newProtNames = cell(0);
    for i = 1:max(protOrder)
        for j = 1:length(protOrder)
            if i == protOrder(j)
                newTemplate = [newTemplate; table2cell(template(j,:))];
                newProtNames = [newProtNames; protNames(j)];
                newDataDir(i,1) = dataDir(j+2);
            end
        end
    end
    dataDir = [dataDir(1:2); newDataDir];
    protNames = inputdlg(newProtNames, "Rename Protocols", [1 60], newTemplate{:,7});
    
    message = sprintf("Choose from these colors: gray, red, blue, light blue,maroon, black, green:\n\n");
    
    
    colors = inputdlg([{message + protNames(1)}; protNames(2:end)], ...
        'Choose plotting colors', [1 60], newTemplate{:,9});
    
    message = sprintf("Choose from these linestyles: ''-'' (solid) or ''--'' (dashed):\n\n");
    linestyles = inputdlg([{message + protNames(1)}; protNames(2:end)], ...
        'Choose line drawing styles', [1 60], newTemplate{:,10}); 
end