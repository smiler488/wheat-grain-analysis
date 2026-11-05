%% Wheat grain size and shape from photographs
% Batch script: segments the grains in every image of the input folder,
% measures length, width, area, perimeter and orientation of each grain,
% saves an annotated image per sample and writes the measurements to
% Excel (one sheet per image) and to one long CSV for all images.
%
% File names are expected as <treatment>-<replicate>.<ext>, e.g. CK-1.jpg
% or T2-3.png; treatment and replicate are parsed into separate columns.
%
% Requires the Image Processing Toolbox (R2019b or newer).
%
% Liangchao Deng (邓良超), MIT License

clc; clear; close all;

%% Settings
inputDir   = 'RAW';         % images to analyse
outputDir  = 'result';      % annotated images, result.xlsx, grains_all.csv
pixelsPerMm = [];           % e.g. 23.6 for a 600 dpi scan; [] reports pixels

opts.minArea       = 50;        % px, smaller objects are dust
opts.threshold     = 'global';  % 'global' (Otsu) or 'adaptive' for uneven light
opts.sensitivity   = 0.4;       % only used with 'adaptive'
opts.splitTouching = false;     % true to separate touching grains (watershed)
opts.clearBorder   = true;      % drop grains cut by the image border

showLabels = true;              % L/W text next to each grain in the figure

%% Files
if ~exist(outputDir, 'dir'), mkdir(outputDir); end
outputExcel = fullfile(outputDir, 'result.xlsx');
outputCsv   = fullfile(outputDir, 'grains_all.csv');

files = [dir(fullfile(inputDir, '*.jpg')); dir(fullfile(inputDir, '*.jpeg')); ...
         dir(fullfile(inputDir, '*.png')); dir(fullfile(inputDir, '*.tif')); ...
         dir(fullfile(inputDir, '*.tiff'))];
if isempty(files)
    error('No images found in %s', inputDir);
end
[~, order] = sort({files.name});
files = files(order);

if isempty(pixelsPerMm)
    scale = 1;  unit = 'px';
else
    scale = 1 / pixelsPerMm;  unit = 'mm';
end

allRows = {};

%% Main loop
for f = 1:numel(files)
    imgName = files(f).name;
    [~, stem] = fileparts(imgName);
    fprintf('Processing %s\n', imgName);

    try
        img = imread(fullfile(inputDir, imgName));
    catch ME
        warning('Cannot read %s: %s', imgName, ME.message);
        continue;
    end

    grains = analyze_grains(img, opts);
    n = numel(grains);
    fprintf('  %d grains\n', n);

    % ---- annotated figure --------------------------------------------
    fig = figure('Visible', 'off');
    imshow(img); hold on;
    for k = 1:n
        g = grains(k);
        c = g.Centroid;
        t = deg2rad(g.Orientation);
        % Image y points down, so a counter-clockwise angle on screen
        % means a negative y step.
        dL = (g.MajorAxisLength / 2) * [cos(t), -sin(t)];
        dW = (g.MinorAxisLength / 2) * [sin(t),  cos(t)];
        rectangle('Position', g.BoundingBox, 'EdgeColor', 'r', 'LineWidth', 1);
        line(c(1) + [-dL(1) dL(1)], c(2) + [-dL(2) dL(2)], 'Color', 'r', 'LineWidth', 1);
        line(c(1) + [-dW(1) dW(1)], c(2) + [-dW(2) dW(2)], 'Color', 'g', 'LineWidth', 1);
        text(c(1), c(2), sprintf('%d', k), 'Color', 'b', 'FontSize', 8, 'FontWeight', 'bold');
        if showLabels
            text(c(1) + 5, c(2) + 12, sprintf('L %.1f  W %.1f', ...
                g.MajorAxisLength * scale, g.MinorAxisLength * scale), ...
                'Color', 'y', 'FontSize', 7);
        end
    end
    hold off;
    print(fig, fullfile(outputDir, [stem '_result.jpg']), '-djpeg', '-r200');
    close(fig);

    % ---- table -------------------------------------------------------
    if n == 0, continue; end
    lenV = [grains.MajorAxisLength]' * scale;
    widV = [grains.MinorAxisLength]' * scale;
    T = table((1:n)', lenV, widV, lenV ./ widV, ...
        [grains.Area]' * scale^2, [grains.Perimeter]' * scale, [grains.Orientation]', ...
        'VariableNames', {'Grain', ['Length_' unit], ['Width_' unit], 'AspectRatio', ...
                          ['Area_' unit '2'], ['Perimeter_' unit], 'Orientation_deg'});
    try
        writetable(T, outputExcel, 'Sheet', stem);
    catch ME
        warning('Could not write sheet %s: %s', stem, ME.message);
    end

    % treatment and replicate from "<treatment>-<replicate>"
    parts = split(string(stem), '-');
    treatment = parts(1);
    replicate = "";
    if numel(parts) > 1, replicate = parts(end); end
    T = addvars(T, repmat(string(stem), n, 1), repmat(treatment, n, 1), ...
        repmat(replicate, n, 1), 'Before', 1, ...
        'NewVariableNames', {'Image', 'Treatment', 'Replicate'});
    allRows{end + 1} = T; %#ok<SAGROW>
end

%% Combined output
if ~isempty(allRows)
    allT = vertcat(allRows{:});
    writetable(allT, outputCsv);
    summary = groupsummary(allT, 'Treatment', {'mean', 'std'}, ...
        {allT.Properties.VariableNames{5}, allT.Properties.VariableNames{6}, ...
         allT.Properties.VariableNames{8}});
    disp(summary);
end
fprintf('Done. Results in %s\n', outputDir);
