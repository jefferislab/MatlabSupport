function writepic(X, filename, metadata)
% write a biorad format file
% writepic(X, filename, metadata);
% writepic(X, filename);

if nargin < 3
    metadata.Height = size(X, 1);
    metadata.Width = size(X, 2);
    metadata.NumImages = size(X, 3);
    switch class(X)
        case 'uint8'
            metadata.BitDepth = 8;
        case 'uint16'
            metadata.BitDepth = 16;
        case {'single', 'double'}
            metadata.BitDepth = 16;
            % who know what the scaling is so just spread it over the range
            X = uint16((X - min(min(min(X)))) / (max(max(max(X))) - min(min(min(X)))) * 2^16);
        otherwise
            error('Unsupported class of image data');
    end
    metadata.LensMagnification = 1;
    metadata.LensFactor = 1;
    metadata.Origin = [0 0];
    metadata.Delta = [0 0];
    metadata.Note = {};
end

fid = fopen(filename, 'w');

	% write header data
	fwrite(fid, metadata.Width, 'int16',0,'l');
	fwrite(fid, metadata.Height, 'int16',0,'l');
	fwrite(fid, metadata.NumImages, 'int16',0,'l');

	fwrite(fid, [0 255], 'int16');
	fwrite(fid, -1, 'int32');
    if metadata.BitDepth == 8
        fwrite(fid, [1 0], 'int16');
    else
        fwrite(fid, [0 0], 'int16');
    end
    tempFileName = filename(find(filename == '\', 1, 'last') + 1:end)';
	fwrite(fid, [tempFileName(1:min([end 32])); zeros(32 - length(tempFileName), 1)], 'char');
	fwrite(fid, [0 7 12345 0 255 7 0], 'int16',0,'l');
	fwrite(fid, metadata.LensMagnification, 'int16',0,'l');
	fwrite(fid, metadata.LensFactor, 'float',0,'l');
	fwrite(fid, [0 0 0], 'int16',0,'l');

	% write image data
	fwrite(fid, X, ['uint' sprintf('%0.0f', metadata.BitDepth)], 0, 'l');

	writeComment(fid, ['PIXEL_BIT_DEPTH = ' metadata.BitDepth])
	writeComment(fid, 'PIC_FF_VERSION = 4.5')

	writeComment(fid, sprintf('AXIS_2 001 %1.4f %1.4f Microns',metadata.Origin(1), metadata.Delta(1)) )
	writeComment(fid, sprintf('AXIS_3 002 %1.4f %1.4f Microns',metadata.Origin(2), metadata.Delta(2)) )

    if isfield(metadata, 'Note')
        for i = 1:numel(metadata.Note)
            writeComment(fid, metadata.Note{i}.text);
        end
    end

    % without this the pic reading software that I have throws an
    % unexpected end of file error
	%fwrite(fid, zeros(640, 1), 'char');

fclose(fid);

function writeComment(fid, comment)

	fwrite(fid, -1, 'int16',0,'l');
	fwrite(fid, 1, 'int32',0,'l');
	fwrite(fid, [0 1 20 0 0],  'int16',0,'l');

    % pad the comment up to 80 characters
    if numel(comment) > 80
        % must truncate the comment or the file will be corrupted, but
        % should never get to here
        comment = comment(1:80);
    end
	fwrite(fid,  [comment  zeros(1, 80 - length(comment))], 'char');


% 	http://rsb.info.nih.gov/ij/plugins/download/Biorad_Reader.java
%   The header of Bio-Rad .PIC files is fixed in size, and is 76 bytes.
%
%   ------------------------------------------------------------------------------
%   'C' Definition              byte    size    Information
%   (bytes)
%   ------------------------------------------------------------------------------
%   int nx, ny;                 0       2*2     image width and height in pixels
%   int npic;                   4       2       number of images in file
%   int ramp1_min, ramp1_max;   6       2*2     LUT1 ramp min. and max.
%   NOTE *notes;                10      4       no notes=0; has notes=non zero
%   BOOL byte_format;           14      2       bytes=TRUE(1); words=FALSE(0)
%   int n;                      16      2       image number within file
%   char name[32];              18      32      file name
%   int merged;                 50      2       merged format
%   unsigned color1;            52      2       LUT1 color status
%   unsigned file_id;           54      2       valid .PIC file=12345
%   int ramp2_min, ramp2_max;   56      2*2     LUT2 ramp min. and max.
%   unsigned color2;            60      2       LUT2 color status
%   BOOL edited;                62      2       image has been edited=TRUE(1)
%   int _lens;                  64      2       Integer part of lens magnification
%   float mag_factor;           66      4       4 byte real mag. factor (old ver.)
%   unsigned dummy[3];          70      6       NOT USED (old ver.=real lens mag.)	