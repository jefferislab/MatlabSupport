function tf = ispic(filename)
%ISPIC Returns true for a Biorad PIC file.
%   TF = ISPIC(FILENAME)

fid = fopen(filename, 'r');
if (fid < 0)
    tf = false;
else
    fseek(fid, 54)
    sig = fread(fid, 1, 'uint16');
    fclose(fid);
    tf = isequal(sig, 12345);
end