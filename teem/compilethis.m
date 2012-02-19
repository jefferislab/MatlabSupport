% Script to compile nrrd IO functions on unix (inc Linux/Mac)
%
% First checks location of unu command line tool (part of teem)
% and checks if teem libraries are installed next to that
% (ie if located /some/dir/bin/unu => teem in /some/dir/lib)
%
% Otherwise checks the following locations (in order):
% /usr/local/lib
% /usr/lib
% /$HOME/local/lib
% /$HOME/lib
%
% NB teem library must be compiled with same binary architecture as matlab 
% (ie 64 bit for 64 bit matlab)
%
% If teem is in a non-standard location, then you must EITHER add the teem
% binaries to your path (and make sure that matlab inherits this path 
% so that ''system unu'' does something in matlab)
% OR edit this script to specify some other location
%
% See http://teem.sourceforge.net/ for more about teem library.

if isunix
	[errval,unu]=system('which unu');
	if errval
		% EDIT HERE! SET teembasedir to directory containing
		% lib/libteem* and include/teem/
		teembasedir='';
	else
		teembindir=fileparts(unu);
		teembasedir=fileparts(teembindir);
	end
	
	% now check default directory for teem libs
	if length(dir(fullfile(teembasedir,'lib','libteem*')))>0
		% we're done since our default worked
		% ... ELSE keep checking likely locations
	elseif length(dir('/usr/local/lib/libteem*'))>0
		teembasedir='/usr/local';
	elseif length(dir('/usr/lib/libteem*'))>0
		teembasedir='/usr';
	else
		homedir=getenv('HOME')
		if length(dir(fullfile(homedir,'local','lib','libteem*')))>0
			teembasedir=fullfile(homedir,'local');
		elseif length(dir(fullfile(homedir,'lib','libteem*')))>0
			teembasedir=homedir;
		else
			error(['Unable to locate teem library.' ...
			' See MatlabSupport/teem/compilethis.m'])
		end
	end
	disp(['Building teem library from: ' teembasedir]);
	includedir=fullfile(teembasedir,'include');
	libdir=fullfile(teembasedir,'lib');
	files=dir('*.c');
	for i=1:length(files)
		mex(files(i).name,['-I' includedir],['-L' libdir],'-lteem','-lz','-lm');
	end
else
	disp(['don''t know how to compile on windows, but shouldn''t be too hard!' ...
	' See MatlabSupport/teem/compilethis.m'])
	% Details of how to build teem (the superpackage containing the nrrd library)
	% (including on windows) are at:
	% 	http://teem.sourceforge.net/build.html 
	% It would also be worth contacting the teem users mailing list
	% teem-users@lists.sourceforge.net
end
