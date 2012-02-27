function test_suite = test_isnrrd
% unit tests for reading nrrds 

initTestSuite;

function test_raw_nrrd
[data,metadata] = readnrrd('4x3x2.nrrd');
assertEqual(metadata.Format,'nrrd')

function test_compare_readnrrd_read3dimage
[data,metadata] = readnrrd('4x3x2.nrrd');
[data2,voxdims,origin] = read3dimage('4x3x2.nrrd');
assertEqual(data,data2);
assertEqual(metadata.Delta,voxdims);
assertEqual(metadata.Origin,origin);
