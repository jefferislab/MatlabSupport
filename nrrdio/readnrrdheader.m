function [headertext] = readnrrdheader(filename)
% 	READNRRDHEADER   Read in the head of a nrrd/nhdr format file
% 		[headertext] = readnrrdheader(filename)
% 
% 	Reads until the it encounters the end of file or a blank line.
%	Does not return the blank line from a nrrd header
% 	
% 	Created by Gregory Jefferis on 2012-02-27.
% 	Copyright (c)  MRC LMB. All rights reserved.

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

end %  function