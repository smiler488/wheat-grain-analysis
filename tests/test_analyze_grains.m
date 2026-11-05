% Tests for analyze_grains.m on synthetic grains (runs in MATLAB and GNU Octave).
%   octave --no-gui --eval "run('tests/test_analyze_grains.m')"
here = fileparts(mfilename('fullpath'));
addpath(fullfile(here, '..'));
if exist('OCTAVE_VERSION', 'builtin')
    pkg load image
    addpath(fullfile(here, 'octave-shims'));
end

img = uint8(220 * ones(400, 600));
[X, Y] = meshgrid(1:600, 1:400);
% grain 1: a = 40, b = 15, rotated 30 deg counter-clockwise on screen, centre (150, 200)
t = deg2rad(30);
dx = X - 150; dy = -(Y - 200);                       % y up
u = dx * cos(t) + dy * sin(t); v = -dx * sin(t) + dy * cos(t);
img((u / 40).^2 + (v / 15).^2 <= 1) = 60;
% grain 2: horizontal, a = 50, b = 20, centre (420, 200)
img(((X - 420) / 50).^2 + ((Y - 200) / 20).^2 <= 1) = 60;
% grains 3 + 4: two touching discs
img((X - 300).^2 + (Y - 330).^2 <= 625 | (X - 345).^2 + (Y - 330).^2 <= 625) = 60;

s = analyze_grains(img);
assert(numel(s) == 3, 'expected 3 objects without splitting');

[~, k] = min(abs([s.MajorAxisLength] - 80));
g = s(k);
assert(abs(g.MajorAxisLength - 80) < 2 && abs(g.MinorAxisLength - 30) < 2, 'axes of grain 1');
assert(abs(g.Orientation - 30) < 2, sprintf('orientation %.1f, expected 30', g.Orientation));

% the major-axis end point drawn by the main script must lie on the grain
o = deg2rad(g.Orientation);
p = round(g.Centroid + 0.8 * (g.MajorAxisLength / 2) * [cos(o), -sin(o)]);
assert(img(p(2), p(1)) == 60, 'major axis drawn outside the grain');

opts.splitTouching = true;
assert(numel(analyze_grains(img, opts)) == 4, 'watershed should split the touching pair');

disp('analyze_grains: all tests passed');
