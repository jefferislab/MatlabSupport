if	strcmp('MACI64',computer)
mex nrrdLoad.c -I/usr/local64/include -L/usr/local64/lib/teem/ -lteem -lz -lm
mex nrrdLoadOrientation.c -I/usr/local64/include -L/usr/local64/lib/teem/ -lteem -lz -lm
mex nrrdSave.c -I/usr/local64/include -L/usr/local64/lib/teem/ -lteem -lz -lm
elseif strcmp('x86_64-unknown-linux-gnu',computer)
	mex nrrdLoad.c -I/public/octave/teem/include -L/public/octave/teem/lib/Teem-1.10.0/ -lteem -lz -lm
	mex nrrdLoadOrientation.c -I/public/octave/teem/include -L/public/octave/teem/lib/Teem-1.10.0/ -lteem -lz -lm
	mex nrrdSave.c -I/public/octave/teem/include -L/public/octave/teem/lib/Teem-1.10.0/ -lteem -lz -lm
else
mex nrrdLoad.c -I/usr/local/include -L/usr/local/lib/teem/ -lteem -lz -lm
mex nrrdLoadOrientation.c -I/usr/local/include -L/usr/local/lib/teem/ -lteem -lz -lm
mex nrrdSave.c -I/usr/local/include -L/usr/local/lib/teem/ -lteem -lz -lm
end
