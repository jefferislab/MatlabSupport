function test_suite = test_isnrrd
% unit test for coord/pixel index conversion

initTestSuite;

function test_good_nrrd
[TF,nrrdversion] = isnrrd('7x6x3-node.nrrd');
assertTrue(TF)
assertEqual(nrrdversion,4)

function test_bad_nrrd
[TF,nrrdversion] = isnrrd('nota.nrrd');
assertFalse(TF)
