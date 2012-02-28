function [ data, info ] = readnrrd( filename, gzipmethod)
%READNRRD Read in a nrrd image file - optionally with metadata
%   [ data, info ] = readnrrd( filename )
%
% data - image data in matlab's default format suitable for imshow
% info - metadata from imnrrdinfo
%
% NB this is a pure matlab implementation that currently has many 
% restrictions including for dimensions (other than 3) and encoding (only
% raw and gzip). For raw files, I find the speed is about 50% more than
% using the nrrd library via mex. However for large gzip encoded files the
% performance difference can be a factor of 5-10x since the gzip encoded
% data must be inflated _on disk_.

if ~isnrrd(filename)
	error('readnrrd:nrrderr',[filename ' is not a nrrd']);
end

if nargin<2
	gzipmethod = 1;
end

info = imnrrdinfo(filename);

if strcmp(info.nrrdfields.encoding,'raw')
	% fine
elseif strcmp(info.nrrdfields.encoding(1:2),'gz')
	if gzipmethod==2
		data = readgzipdata(info);
		return
	end
else
	error('readnrrd:limitation',...
	['unable to open files with encoding: ',info.nrrdfields.encoding]);
end

% note specifying endian-ness on opening of file
fid = fopen(filename, 'r', info.endian);

if fid < 0
	error('Unable to open image file');
end

tmpfile='';
try
	if isfield(info.nrrdfields,'datafile')
		% this is a detached header
		fclose(fid);
		if iscellstr(info.nrrdfields.datafile)
			error ('readnrrd:limitation',...
				'Currently unable to open nrrds with more than 1 data file)');
		end
		fid=fopen(info.nrrdfields.datafile,'r',info.endian);
	end
	
	%line skip if required
	if ~isempty(info.lineskip)
		for i = 1:info.lineskip
			fgetl(fid);
		end
	elseif ~isfield(info.nrrdfields,'datafile')
		% skip to end of header if this is a regular (non-detached) nrrd
		if fseek(fid,info.headerlen,'bof')<0
			error('readnrrd:seekerr','Unable to seek to end of header');
		end
	end
	
	% copy gzipped data block to temporary file if required
	if gzipmethod==1 && strcmp(info.nrrdfields.encoding(1:2),'gz')
		tmpfile = copy_gzipdata_to_temp_file(fid);
		fid=fopen(tmpfile,'r',info.endian);
	end

	% byte skip if required
	if ~isempty(info.byteskip)
		if info.byteskip == -1
			if strcmp(info.nrrdfields.encoding(1:2),'gz')
				error('readnrrd:nrrderr','cannot use byte skip: -1 when for compressed data');
			end
			% seek back data length from end of file
			if fseek(fid,prod(info.size)*(info.BitDepth/8),'eof')<0
				error('readnrrd:seekerr','Unable to seek back from head of data');
			end
		else
			fseek(fid,info.byteskip,'cof');
		end
	end
	
	% actually read in data (in matlab's standard form)
	data = zeros(info.Height, info.Width, info.NumImages, info.type);
	% note that prefixing fread data type with * returns it AS THAT TYPE
	for x = 1:info.NumImages
		data(:,:,x) = fread(fid, [info.Width, info.Height], ['*' info.type])';
	end
catch ME
	if ~strcmp(ME.identifier(1:9),'readnrrd:')
		error('readnrrd:genericloaderror',...
			['Unable to read image data:' ME.identifier ME.message]);
	else
		rethrow(ME);
	end
end
fclose(fid);
% clean up temp file if required
if ~isempty(tmpfile)
	delete(tmpfile);
end
end

function [data] = readgzipdata(ni)
	% this works BUT is very, very slow for large files
	f=java.io.File(ni.Filename);
	if ~f.canRead()
		error(['unable to open ' ni.Filename 'for reading']);
	end
	
	fis=java.io.FileInputStream(f);
	% note that we don't implement all the permutations of 
	% skips and data files since this function is just left here 
	% for testing purposes
	fis.skip(ni.headerlen);
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

function [tmpfile] = copy_gzipdata_to_temp_file(fid,bufsize)
  % nb bufsize = inf => read file in one go, defaults to 1e6 bytes
	% this time, we are going to try copying the data to a temporary file and
	% then reading that in.
	% assume that we are given a fid ready to go
	if nargin<2
		bufsize=1e6;
	end
	tmpfile = tempname;
	fod = fopen([tmpfile '.gz'],'w');
	while ~feof(fid)
		% read in up to buf bytes
		[buf,count] = fread(fid,bufsize,'*uint8');
		fwrite(fod,buf(1:count),'uint8');
	end
	fclose(fod);
	fclose(fid);
	% now that we've finished copying, clean up temporary files
	gunzip([tmpfile '.gz']);
	delete([tmpfile '.gz']);
end