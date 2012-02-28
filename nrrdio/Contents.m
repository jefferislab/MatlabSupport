% NRRDIO - Pure Matlab code to read simple nrrd files
%
% Currently only reads 3d data in raw or gzip encoding
%
% Files
%   imnrrdinfo     - parse nrrd header to extract key metadata
%   isnrrd         - Returns true for a Nrrd (Nearly Raw Raster Data) image.
%   readnrrd       - Read in a nrrd image file - optionally with metadata
%   readnrrdheader - Read in the header of a nrrd/nhdr format file
% 
% See the tests directory for usage examples/test data
%
% GPL>=2 license
% Copyright (c) Gregory Jefferis 2012
