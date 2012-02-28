function test_suite = test_isnrrd
% unit tests for reading nrrds 

initTestSuite;

function test_raw_nrrd
[data,metadata] = readnrrd('4x3x2.nrrd');
assertEqual(metadata.Format,'nrrd')

function test_raw_nhdr
% read data from nhdr file
[data,metadata] = readnrrd('image-16.PIC.nhdr');
assertEqual(metadata.Format,'nrrd')
if exist('read3dimage','file')
	[data2,voxdims2,origin2] = read3dimage('image-16.PIC');
	assertEqual(data,data2);
	% note use of relative tolerance since one comes from string->double
	assertAlmostEqual(metadata.Delta,voxdims2,1e-6);
	% read3dimage returns empty origin if not present in nrrd
	% whereas always returns something from PIC
	%assertAlmostEqual(origin,origin2);
else
	warning('unable to locate read3dimage for additional testing')
end

function test_gz_nrrd
[data,metadata] = readnrrd('4x3x2.nrrd');
[data2,metadata2] = readnrrd('4x3x2-gz.nrrd');
assertEqual(metadata2.Format,'nrrd')
assertEqual(data,data2)

function test_gz_nrrd_bothways
% cross-compare the tempfile and java approaches 
[data,metadata] = readnrrd('4x3x2-gz.nrrd');
[data2,metadata2] = readnrrd('4x3x2-gz.nrrd',2);
assertEqual(metadata2.Format,'nrrd')
assertEqual(data,data2)

function test_compare_readnrrd_read3dimage
if exist('read3dimage','file')
	[data,metadata] = readnrrd('4x3x2.nrrd');
	[data2,voxdims,origin] = read3dimage('4x3x2.nrrd');
	assertEqual(data,data2);
	assertEqual(metadata.Delta,voxdims);
	assertEqual(metadata.Origin,origin);
else
	warning('unable to locate read3dimage for additional testing')
end

function test_compare_complex_read3dimage
if exist('read3dimage','file')
	[data,voxdims,origin] = read3dimage('image-16-gz.nrrd');
	[data2,voxdims2,origin2] = read3dimage('image-16.PIC');
	assertEqual(data,data2);
	% note use of relative tolerance since one comes from string->double
	assertAlmostEqual(voxdims,voxdims2,1e-6);
	% read3dimage returns empty origin if not present in nrrd
	% whereas always returns something from PIC
	%assertAlmostEqual(origin,origin2);
else
	warning('unable to locate read3dimage for additional testing')
end