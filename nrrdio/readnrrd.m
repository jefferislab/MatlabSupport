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

if strcmp(info.nrrdfields.encoding,'raw')
	% fine
elseif strcmp(info.nrrdfields.encoding(1:2),'gz')
	data = readgzipdata(info);
	return
else
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

function [data] = readgzipdata(ni)
	f=java.io.File(ni.Filename);
	if ~f.canRead()
		error(['unable to open ' filename 'for reading']);
	end
	
	fis=java.io.FileInputStream(f);
	fis.skip(ni.offset);
	gzfis=java.util.zip.GZIPInputStream(fis,1000);
	data=zeros(ni.Height,ni.Width,ni.NumImages,ni.type);
	plane=zeros(ni.Height,ni.Width,ni.type);
	bytesfortype=ni.BitDepth/8;
	[str,maxsize,endian]=computer();
	if ni.endian=='n' || (ni.endian==lower(endian))
		swap = 0;
	else
		swap = 1;
	end
	buf=uint8(bytesfortype);
	for h=1:ni.NumImages
		for i=1:ni.Height
			for j=1:ni.Width
				for k=1:bytesfortype
					buf(k)=gzfis.read();
					if buf(k)<0
						error(['premature end of gzip data for: ' fi.Filename]);
					end
				end
				if swap
					plane(i,j)=typecast(swapbytes(buf),ni.type);
				else
					plane(i,j)=typecast(buf,ni.type);
				end
			end
		end
		data(:,:,h)=plane;
	end
	fis.close();
end