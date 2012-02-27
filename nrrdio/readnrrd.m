function [ data, info ] = readnrrd( filename)
%READNRRD Read in a nrrd image file - optionally with metadata
%   [ data, info ] = readnrrd( filename )
%
% data     - image data in matlab's default format suitable for imshow
% info - metadata from imnrrdinfo
%
% NB this is a pure matlab implementation

if ~isnrrd(filename)
	error([filename ' is not a nrrd']);
end

info = imnrrdinfo(filename);

if ~info.nrrdfields.encoding=='raw'
	error(['unable to open files with encoding: ',info.nrrdfields.encoding]);
end

% note specifying endian-ness on opening of file
fid = fopen(filename, 'r', info.endian);

if fid < 0
	error('Unable to open image file');
end

try 
	status = fseek(fid,info.offset,'bof');

	% actually read in data (in matlab's standard form)
	data = zeros(info.Height, info.Width, info.NumImages, info.type);
	for x = 1:info.NumImages
		data(:,:,x) = fread(fid, [info.Width, info.Height], info.type)';
	end
catch
	error('Unable to read image data');
end
fclose(fid);
end
