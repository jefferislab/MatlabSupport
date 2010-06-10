function metadata = impicinfo(filename)
% IMPICINFO read in the metadata from a Biorad .pic image file
%
% metadata = impicinfo(filename)
% see also ispic, readpic

% adapted from:
% http://www.bu.edu/cism/cismdx/ref/dx.Samples/util/biorad-pic/PIC2dx.c
% http://rsb.info.nih.gov/ij/plugins/download/Biorad_Reader.java

% constants
HEADER_LEN  = 76;

% read header
fid = fopen(filename, 'r');

if fid ~= -1
    % Initialize universal structure fields to fix the order
    metadata.Filename = '';
    metadata.FileModDate = [];
    metadata.FileSize = [];
    metadata.Format = 'pic';
    metadata.FormatVersion = [];
    metadata.Width = [];
    metadata.Height = [];
    metadata.BitDepth = [];
    metadata.ColorType = 'grayscale';
    filename = fopen(fid);  % Get the full path name if not in pwd
    d = dir(filename);      % Read directory information

    metadata.Filename = filename;
    metadata.FileModDate = d.date;
    metadata.FileSize = d.bytes;

    % check to make sure that the file isn't zero length
    fseek(fid, 0, 'eof');
    endOfFile = ftell(fid);
    if endOfFile > HEADER_LEN
        % read header
        fseek(fid, 0, 'bof');
        metadata.Width = fread(fid, 1, 'int16',0,'l');
        metadata.Height = fread(fid, 1, 'int16',0,'l');
        metadata.NumImages = fread(fid, 1, 'int16',0,'l');
        metadata.Ramp1 = fread(fid, 2, 'int16',0,'l');
        metadata.Notes = fread(fid, 1, 'int32');
        byteFormat = fread(fid, 1, 'int16',0,'l');
        metadata.ImageNumber = fread(fid, 1, 'int16',0,'l');
        fread(fid, 32, 'char');
        if fread(fid, 1, 'int16',0,'l')
            % merged format is not currently supported
            metadata = [];
            return
        end

        metadata.ColorStatus1 = fread(fid, 1, 'int16',0,'l');
        if fread(fid, 1, 'int16',0,'l') ~= 12345
            metadata = [];
            return
        end

        metadata.Ramp2 = fread(fid, 2, 'int16',0,'l');
        metadata.ColorStatus2 = fread(fid, 1, 'int16',0,'l');
        metadata.IsEdited = fread(fid, 1, 'int16',0,'l');
        metadata.LensMagnification = fread(fid, 1, 'int16',0,'l');
        metadata.LensFactor = fread(fid, 1, 'float32',0,'l');
        fread(fid, 3, 'int16',0,'l');

        if byteFormat == 1
            metadata.BitDepth = 8;
        else
            metadata.BitDepth = 16;
        end

        % read notes
        fseek(fid, metadata.Width * metadata.Height * metadata.NumImages * metadata.BitDepth / 8, 'cof');
        notesOffset = ftell(fid);
        [metadata] = getAxisInfo (fid,notesOffset,metadata,endOfFile);
        fclose(fid);
    else
        metadata = []; %tell calling subroutine that the file was zero length
    end
else
    metadata = []; %tell calling subroutine that no file was found
end

end

function [metadata] = getAxisInfo(fid,notesOffset,metadata,endOfFile)
    NOTE_LEN    = 96;

	NOTE_TYPE_LIVE = 1;         % Information about live collection
	NOTE_TYPE_FILE1 = 2;        % Note from image #1
	NOTE_TYPE_NUMBER = 3;       % Number in multiple image file
	NOTE_TYPE_USER = 4;         % User notes generated notes
	NOTE_TYPE_LINE = 5;         % Line mode info
	NOTE_TYPE_COLLECT = 6;      % Collect mode info
	NOTE_TYPE_FILE2 = 7;        % Note from image #2
	NOTE_TYPE_SCALEBAR = 8;     % Scale bar info
	NOTE_TYPE_MERGE = 9;        % Merge Info
	NOTE_TYPE_THRUVIEW = 10;    % Thruview Info
	NOTE_TYPE_ARROW = 11;       % Arrow info
	NOTE_TYPE_VARIABLE = 20;    % Again internal variable ,except held as
	NOTE_TYPE_STRUCTURE = 21;   % a structure.

	AXT_D = 1;                  % distance in microns
	AXT_T = 2;                  % time in sec
	AXT_A = 3;                  % angle in degrees
	AXT_I = 4;                  % intensity in grey levels
	AXT_M4 = 5;                 % 4-bit merged image
	AXT_R = 6;                  % Ratio
	AXT_LR = 7;                 % Log Ratio
	AXT_P = 8;                  % Product
	AXT_C = 9;                  % Calibrated
	AXT_PHOTON = 10;			% intensity in photons/sec
	AXT_RGB = 11;               % RGB type
	AXT_SEQ = 12;               % SEQ type (eg 'experiments')
	AXT_6D = 13;                % 6th level of axis
	AXT_TC = 14;				% Time Course axis
	AXT_S = 15;                 % Intensity signoid cal
	AXT_LS = 16;				% Intensity log signoid cal
	AXT_BASE = base2dec('FF', 16);	% mask for axis TYPE
	AXT_XY = base2dec('100', 16);	% axis is XY, needs updating by LENS
	AXT_WORD = base2dec('200', 16);  % axis is word. only corresponds to axis[0]
	
	% read all of the notes
    fseek(fid, notesOffset, 'bof');
    noteIndex = 1;

    while notesOffset + NOTE_LEN * (noteIndex - 1) <= endOfFile
        metadata.Note{noteIndex} = readNote(fid,noteIndex,notesOffset);

        if metadata.Note{noteIndex}.type == NOTE_TYPE_VARIABLE
            if strfind(metadata.Note{noteIndex}.text, 'AXIS_2') == 1
                % horizontal axis
                tempData = sscanf(metadata.Note{noteIndex}.text(7:end), ' %d %g %g %s');
                axisType = tempData(1);
                if axisType == AXT_D
                    metadata.Origin(1) = tempData(2);
                    metadata.Delta(1) = tempData(3);
                end
                metadata.Units{1} = char(tempData(4:end)');
            elseif strfind(metadata.Note{noteIndex}.text, 'AXIS_3') == 1
                % vertical axis
                tempData = sscanf(metadata.Note{noteIndex}.text(7:end), ' %d %g %g %s');
                axisType = tempData(1);
                if axisType == AXT_D
                    metadata.Origin(2) = tempData(2);
                    metadata.Delta(2) = tempData(3);
                end
                metadata.Units{2} = char(tempData(4:end)');
            elseif strfind(metadata.Note{noteIndex}.text, 'AXIS_4') == 1
                % z axis
                tempData = sscanf(metadata.Note{noteIndex}.text(7:end), ' %d %g %g %s');
                axisType = tempData(1);
                if axisType == AXT_D
                    metadata.Origin(3) = tempData(2);
                    metadata.Delta(3) = tempData(3);
                end
                metadata.Units{3} = char(tempData(4:end)');
            elseif strfind(metadata.Note{noteIndex}.text, 'AXIS_9') == 1
                tempData = sscanf(metadata.Note{noteIndex}.text(7:end), ' %d %g %g %s');
                axisType = tempData(1);
                if axisType == AXT_RGB
                    metadata.Origin(4) = tempData(2);
                    metadata.Delta(4) = tempData(3);
                    metadata.Units{4} = char(tempData(4:end)');
                end
            elseif strfind(metadata.Note{noteIndex}.text, 'INFO_FRAME_RATE') == 1
                metadata.FramesPerSecond = sscanf(metadata.Note{noteIndex}.text(14:end), ' %d');
            elseif strfind(metadata.Note{noteIndex}.text, 'INFO_OBJECTIVE_NAME = ') == 1
                metadata.Objective = metadata.Note{noteIndex}.text(23:end);
                metadata.Objective = metadata.Objective(metadata.Objective ~= char(0));
            elseif strfind(metadata.Note{noteIndex}.text, 'PIC_FF_VERSION = ') == 1
                metadata.FormatVersion = str2double(metadata.Note{noteIndex}.text(18:end));
            else
                % add any note you care about here

            end
        else
            % add info about other note types here

        end
        noteIndex = noteIndex + 1;
    end
end

function note = readNote(fid,index,notesOffset)
	NOTE_LEN    = 96;

    fseek(fid, notesOffset + (index - 1) * NOTE_LEN, 'bof');
    note.level = fread(fid, 1, 'int16',0,'l');
    note.next = fread(fid, 1, 'int32',0,'l');
    note.num = fread(fid, 1, 'int16',0,'l');
    note.status = fread(fid, 1, 'int16',0,'l');
    note.type = fread(fid, 1, 'int16',0,'l');
    note.x = fread(fid, 1, 'int16',0,'l');
    note.y = fread(fid, 1, 'int16',0,'l');
    note.text = char(fread(fid, 80, 'char')');
end