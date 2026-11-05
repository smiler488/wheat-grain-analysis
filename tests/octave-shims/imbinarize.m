function bw = imbinarize(I, varargin)
%IMBINARIZE Minimal stand-in for GNU Octave, which lacks imbinarize.
%   Global Otsu only; used by the CI tests, not needed in MATLAB.
bw = im2bw(I, graythresh(I));
end
