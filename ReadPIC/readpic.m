function data = readpic(filename)
% read in a Biorad .pic image file
% image = readpic(filename)

% adapted from:
% http://www.bu.edu/cism/cismdx/ref/dx.Samples/util/biorad-pic/PIC2dx.c
% http://rsb.info.nih.gov/ij/plugins/download/Biorad_Reader.java

info = impicinfo(filename);

fid = fopen(filename, 'r');
    % skip over the header
    fseek(fid, 76, 'bof');

    % read data
    data = zeros(info.Height, info.Width, info.NumImages, ['uint' sprintf('%0.0f', info.BitDepth)]);
    for x = 1:info.NumImages
        data(:,:,x) = fread(fid, [info.Width, info.Height], ['uint' sprintf('%0.0f', info.BitDepth)])';
    end
fclose(fid);