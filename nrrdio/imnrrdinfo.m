function [ metadata ] = imnrrdinfo( filename )
%IMNRRDINFO parse nrrd header to extract key metadata
% [ metadata ] = imnrrdinfo( filename )
% 
% Note that Origin and Delta are both row vectors, following impicinfo's
% lead
%
% Pure matlab implementation - currently limited to 3d images
% See http://teem.sourceforge.net/nrrd/format.html for details of nrrd format
% See also ISNRRD, IMFINFO

[nrrdtf, nrrdversion] = isnrrd(filename);

metadata=[];

if ~nrrdtf
	return;
end

% read header
[h, offset] = readnrrdheader(filename);
fields=[];
% now parse header - start from line _after_ NRRD magic
for i = 2:length(h)
	% for each line, figure out if it is
	% comment, field, or keyval
	if h{i}(1)=='#'
		% a comment
	elseif strfind(h{i},':=')
		% a keyval
	elseif strfind(h{i},': ')
		% a field
		k = strfind(h{i},': ');
		field=h{i}(1:(k-1));
		value=h{i}((k+2):end);
		%disp([field ':::' value]);
		% fields we want
		% dimension,sizes, space directions
		% centers
		% remove all spaces in field name
		field=strrep(field,' ','');
		fields.(field)=value;
	else
		error(['Bad nrrd line: ' h{i}]);
	end
end
metadata.nrrdfields=fields;
metadata.Format = 'nrrd';
metadata.FormatVersion = nrrdversion;
metadata.dim = str2num(fields.('dimension'));
metadata.size = str2num(fields.('sizes'));
metadata.Width = metadata.size(1);
metadata.Height = metadata.size(2);
if metadata.dim>2
	metadata.NumImages = metadata.size(3);
else
	metadata.NumImages = 1;
end
metadata.offset = offset;
% handle space information
metadata.Origin=[];
metadata.Delta=[];
metadata.spacedim=metadata.dim;
if isfield(fields,'spacedimension') || isfield(fields,'space')
	% don't know how to deal with space field
	if isfield(fields,'space')
		error('Do not know how to parse space field');
	end
	metadata.spacedim=str2num(fields.spacedimension);
	if ~metadata.spacedim==3
		error('Can only handle 3d data');
	end
	% deal with this
	spacedirs=sscanf(fields.('spacedirections'),...
		repmat('(%f,%f,%f) ',[1 metadata.spacedim]));
	spacedirs=reshape(spacedirs,metadata.spacedim,metadata.spacedim);
	
	% check no off diagonal elements
	trilvals=tril(spacedirs,-1);triuvals=triu(spacedirs,1);
	if any(trilvals(:)) || any(triuvals(:))
		error('unable to handle off diagonal elements in space directions');
	end
	metadata.Delta = diag(spacedirs)';
	if(isfield(fields,'spaceorigin'))
		% FIXME - should really generalise to dims other than 3
		metadata.Origin = sscanf(fields.spaceorigin,'(%f,%f,%f)')';
	end
	
elseif isfield(fields,'spacings')
	% deal with this
	spacings=sscanf(fields.spacings,'%f');
	metadata.Delta=spacings(~isnan(spacings))';
	metadata.spacedim=length(metadata.Delta);
else
	% no space information
end


% handle data type
[metadata.type, metadata.BitDepth] = standard_nrrdtype(fields.type);
if isfield(fields,'endian')
	metadata.endian = fields.endian(1);
else
	metadata.endian = 'n';
end
metadata.ColorType = 'grayscale';

fid = fopen(filename, 'r');
filename = fopen(fid);
fclose(fid);

% Get the full path name if not in pwd
d = dir(filename);      % Read directory information

metadata.Filename = filename;
metadata.FileModDate = d.date;
metadata.FileSize = d.bytes;

end

function [ntype, bits] = standard_nrrdtype(ntype)
	switch(ntype)
		case 'block'
			bits = [];
		case 'float'
			bits = 32;
		case 'double'
			bits = 64;
		case {'signed char', 'int8', 'int8_t'}
			ntype = 'int8';
			bits = 8;
		case {'uchar', 'unsigned char', 'uint8', 'uint8_t'}
			ntype = 'uint8';
			bits = 8;
		case {'short', 'short int', 'signed short', 'signed short int', 'int16', 'int16_t'}
			ntype = 'int16';
			bits = 16;
		case {'ushort', 'unsigned short', 'unsigned short int', 'uint16', 'uint16_t'}
			ntype = 'uint16';
			bits = 16;
		case {'int', 'signed int', 'int32', 'int32_t'}
			ntype = 'int32';
			bits = 32;
		case {'uint', 'unsigned int', 'uint32', 'uint32_t'}
			ntype = 'uint32';
			bits = 32;
		case {'longlong', 'long long', 'long long int', 'signed long long', 'signed long long int', 'int64', 'int64_t'}
			ntype = 'int64';
			bits = 64;
		case {'ulonglong', 'unsigned long long', 'unsigned long long int', 'uint64', 'uint64_t'}
			ntype = 'uint64';
			bits = 64;
		otherwise
			error(['Invalid nrrd type: ',ntype]);
	end
end