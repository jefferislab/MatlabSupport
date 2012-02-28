function [headertext,byteoffset] = readnrrdheader(filename)
% READNRRDHEADER   Read in the header of a nrrd/nhdr format file
% [headertext, byteoffset] = readnrrdheader(filename)
% Output:
% headertext - cell array of header lines
% byteoffset - position of end of header (should be start of data)
% 
% Reads until the it encounters the end of file or a blank line.
% Does not return the blank line from a nrrd header

fid = fopen(filename, 'r');

headertext={};
k = 0;
while ~feof(fid)
	curr = fgetl(fid);
	if isempty(curr)
		% blank line signifies end of header
		break
	end
	k=k+1;
    headertext{k} = curr;
end

byteoffset = ftell(fid);
fclose(fid);

end %  function