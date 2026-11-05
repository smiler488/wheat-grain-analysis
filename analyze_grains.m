function [stats, bw] = analyze_grains(img, opts)
%ANALYZE_GRAINS Segment grains in one image and measure their shape.
%
%   [stats, bw] = analyze_grains(img, opts)
%
%   img   RGB or greyscale image, grains darker than the background
%   opts  struct with optional fields
%           .minArea          smallest object kept, px            (default 50)
%           .threshold        'global' (Otsu) or 'adaptive'       (default 'global')
%           .sensitivity      adaptive threshold sensitivity 0-1  (default 0.4)
%           .splitTouching    split touching grains by watershed  (default false)
%           .clearBorder      drop grains cut by the image border (default true)
%
%   stats  struct array, one element per grain, with fields
%          Area, MajorAxisLength, MinorAxisLength, Orientation,
%          Centroid, BoundingBox, Perimeter (all in pixels / degrees)
%   bw     final binary mask
%
%   Orientation follows regionprops: degrees from the x axis to the major
%   axis, counter-clockwise as seen on screen (image y points down).
%
%   Liangchao Deng (邓良超), MIT License

if nargin < 2, opts = struct(); end
opts = set_default(opts, 'minArea', 50);
opts = set_default(opts, 'threshold', 'global');
opts = set_default(opts, 'sensitivity', 0.4);
opts = set_default(opts, 'splitTouching', false);
opts = set_default(opts, 'clearBorder', true);

if size(img, 3) == 3
    gray = rgb2gray(img);
else
    gray = img;
end

% Grains are darker than the background; invert so that they become the
% bright foreground expected by imbinarize.
inv = imcomplement(gray);

if strcmpi(opts.threshold, 'adaptive')
    bw = imbinarize(inv, 'adaptive', 'ForegroundPolarity', 'bright', ...
                    'Sensitivity', opts.sensitivity);
else
    bw = imbinarize(inv);   % Otsu
end

bw = bwareaopen(bw, opts.minArea);
bw = imfill(bw, 'holes');

if opts.splitTouching
    % Marker-controlled watershed on the distance transform
    d = -bwdist(~bw);
    d = imhmin(d, 2);
    L = watershed(d);
    bw(L == 0) = false;
    bw = bwareaopen(bw, opts.minArea);
end

if opts.clearBorder
    bw = imclearborder(bw);
end

stats = regionprops(bw, 'Area', 'MajorAxisLength', 'MinorAxisLength', ...
    'Orientation', 'Centroid', 'BoundingBox', 'Perimeter');
end

function s = set_default(s, name, value)
if ~isfield(s, name) || isempty(s.(name))
    s.(name) = value;
end
end
