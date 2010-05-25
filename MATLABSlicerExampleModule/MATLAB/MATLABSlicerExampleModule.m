function MATLABSlicerExampleModule( in1NhdrFile, in2NhdrFile, out1NhdrFile, out2NhdrFile )
% This example function reads in two nrrd files and outputs two nrrd files
% that are simple additions and subtractions of the input files.
%
% Contributed by John Melonakos, jmelonak@ece.gatech.edu, (2008).
%

fprintf('Executing MATLABSlicerExampleModule.m ... ');

in1 = nrrdLoadWithMetadata( in1NhdrFile );
in2 = nrrdLoadWithMetadata( in2NhdrFile );

out1 = in1;
out2 = in2;
out1.data = in1.data + in2.data;
out2.data = in1.data - in2.data;

nrrdSaveWithMetadata( out1NhdrFile, out1 );
nrrdSaveWithMetadata( out2NhdrFile, out2 );

fprintf('Done!\n');

exit;
