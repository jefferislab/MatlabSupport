function [tf,version] = isnrrd(filename)
% ISNRRD Returns true for a Nrrd (Nearly Raw Raster Data) image.
%   [TF,version] = ISNRRD(FILENAME)
% 
% Version is the nrrd version number.
% See http://teem.sourceforge.net/nrrd/format.html for details of nrrd format
% 	Created by Gregory Jefferis on 2011-10-23.
% 	Copyright (c)  MRC LMB. All rights reserved.

version = 0;
fid = fopen(filename, 'r');
if (fid < 0)
    tf = false;
else
    nmagic = fgets(fid,8);
    fclose(fid);
    tf = isequal(nmagic(1:7), 'NRRD000');
	version=str2num(nmagic(8));
end

end %  function