%% 小麦籽粒图像分析与量化
% 此脚本用于分析小麦籽粒图像，计算籽粒的形态学特征（长度、宽度、面积等）
% 并将结果可视化和保存到Excel文件中
%
% 作者：
% 日期：2025年9月

%% 清理工作空间
clc;
clear;
close all;

%% 设置路径
% 定义输入和输出文件夹
inputDir = 'RAW';
outputDir = 'result';
outputExcel = fullfile(outputDir, 'result.xlsx');

% 确保输出目录存在
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% 定义处理组和重复
treat = ["CK", "T1", "T2", "T3"];
repeat = 1:5;

%% 主处理循环
for i = 1:length(treat)
    for j = repeat
        % 构建文件名
        imgName = sprintf('%s-%d.jpg', treat(i), j);
        inputPath = fullfile(inputDir, imgName);
        resultImgName = sprintf('%s-%d_result.jpg', treat(i), j);
        outputPath = fullfile(outputDir, resultImgName);
        
        fprintf('处理图像: %s\n', imgName);
        
        % 检查输入文件是否存在
        if ~exist(inputPath, 'file')
            warning('找不到文件: %s，跳过处理', inputPath);
            continue;
        end
        
        % 读取图像
        try
            image = imread(inputPath);
        catch ME
            warning('读取图像失败: %s\n错误: %s', inputPath, ME.message);
            continue;
        end
        
        % 转换为灰度图像
        if size(image, 3) == 3
            grayImage = rgb2gray(image);
        else
            grayImage = image;
        end
        
        % 图像预处理
        % 反转图像颜色，使小麦籽粒变暗，背景变亮
        invertedImage = imcomplement(grayImage);
        
        % 自适应二值化
        binaryImage = imbinarize(invertedImage);
        
        % 噪声滤除和填充孔洞
        binaryImage = bwareaopen(binaryImage, 50);
        binaryImage = imfill(binaryImage, 'holes');
        
        % 标记连通区域
        [labeledImage, numberOfGrains] = bwlabel(binaryImage);
        
        % 测量每个小麦籽粒的特征
        grainData = regionprops(labeledImage, 'MajorAxisLength', 'MinorAxisLength', ...
            'Area', 'BoundingBox', 'Centroid', 'Orientation');
        
        % 准备绘制结果的图像
        figure('Name', sprintf('分析结果: %s', imgName), 'NumberTitle', 'off');
        imshow(image);
        hold on;
        
        % 循环遍历每个小麦籽粒并绘制相关信息
        for k = 1:numberOfGrains
            % 获取单个小麦籽粒的属性
            grainLength = grainData(k).MajorAxisLength;
            grainWidth = grainData(k).MinorAxisLength;
            grainArea = grainData(k).Area;
            grainOrientation = grainData(k).Orientation;
            centroid = grainData(k).Centroid;
            majorAxisLength = grainData(k).MajorAxisLength;
            minorAxisLength = grainData(k).MinorAxisLength;
            orientationRadians = deg2rad(grainData(k).Orientation);
            
            % 绘制边界框和中心点
            rectangle('Position', grainData(k).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
            plot(grainData(k).Centroid(1), grainData(k).Centroid(2), 'b+');
            
            % 计算椭圆的最长轴端点
            deltaXL = (majorAxisLength/2) * cos(orientationRadians);
            deltaYL = (majorAxisLength/2) * sin(orientationRadians);
            line([centroid(1)-deltaXL, centroid(1)+deltaXL], ...
                [centroid(2)-deltaYL, centroid(2)+deltaYL], 'Color', 'r', 'LineWidth', 1);
            
            % 计算椭圆的最短轴端点
            deltaXW = (minorAxisLength/2) * sin(orientationRadians);
            deltaYW = (minorAxisLength/2) * cos(orientationRadians);
            line([centroid(1)-deltaXW, centroid(1)+deltaXW], ...
                [centroid(2)+deltaYW, centroid(2)-deltaYW], 'Color', 'g', 'LineWidth', 1);
            
            % 标注编号
            text(centroid(1), centroid(2), sprintf('%d', k), ...
                'Color', 'b', 'FontSize', 8, 'FontWeight', 'bold');
            
            % 在图像旁边显示长度、宽度信息
            text(grainData(k).Centroid(1) + 5, grainData(k).Centroid(2), ...
                sprintf('L: %.2f, W: %.2f, A: %.2f, O: %.2f', ...
                grainLength, grainWidth, grainArea, grainOrientation), ...
                'Color', 'y', 'FontSize', 8, 'FontWeight', 'bold');
        end
        
        hold off;
        
        % 保存结果图像
        saveas(gcf, outputPath);
        
        % 输出结果
        fprintf('总粒数: %d\n', numberOfGrains);
        
        % 创建数据表并保存到Excel
        grainSizes = table((1:numberOfGrains)', [grainData.MajorAxisLength]', ...
            [grainData.MinorAxisLength]', [grainData.Area]', [grainData.Orientation]', ...
            'VariableNames', {'GrainNumber', 'Length', 'Width', 'Area', 'Orientation'});
        
        % 显示数据表
        disp(grainSizes);
        
        % 将数据写入Excel文件
        try
            writetable(grainSizes, outputExcel, 'Sheet', imgName);
        catch ME
            warning('写入Excel失败: %s\n错误: %s', outputExcel, ME.message);
        end
        
        % 关闭图形窗口
        close;
    end
end

fprintf('处理完成！结果已保存到 %s 文件夹\n', outputDir);