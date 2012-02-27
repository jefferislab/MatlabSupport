function test_suite = test_imnrrdinfo
% unit test for nrrd info

initTestSuite;

function test_good_nrrd
inf=imnrrdinfo('7x6x3-origin.nrrd');
% nrrdfields: [1x1 struct]
%            Format: 'nrrd'
%     FormatVersion: 4
%               dim: 3
%              size: [7 6 3]
%             Width: 7
%            Height: 6
%            Origin: [3x1 double]
%             Delta: [3x1 double]
%          spacedim: 3
%          BitDepth: []
%         ColorType: 'grayscale'
%          Filename: '/GD/dev/Matlab/ReadNRRD/7x6x3-origin.nrrd'
%       FileModDate: '26-Feb-2012 18:41:42'
%          FileSize: 389

assertEqual(inf.Format,'nrrd');
assertEqual(inf.FormatVersion,4);
assertEqual(inf.dim,3);
assertEqual(inf.spacedim,3)
assertEqual(inf.size,[7 6 3]);
assertEqual(inf.Width,7);
assertEqual(inf.Height,6);
assertEqual(inf.Origin,[0 0 0]);
assertEqual(inf.Delta,[0.5 0.4 1.0]);

function test_nrrd_with_origin
inf=imnrrdinfo('7x6x3-neworigin.nhdr');
inf2=imnrrdinfo('7x6x3-neworigin.nhdr');
assertEqual(inf2.Origin,[10 20 15])

function test_nrrd_with_spacing
inf=imnrrdinfo('SABB4-1_02.pic.nhdr');
assertEqual(inf.Delta,[0.290601 0.293551 1]);

function test_compare_nrrdLoadOrientation

if exist('nrrdLoadOrientation','file')
	inf=imnrrdinfo('7x6x3-origin.nrrd');
	inf2=nrrdLoadOrientation('7x6x3-origin.nrrd');
	assertEqual(inf.Delta',diag(inf2));
end

function test_compare_nrrdLoadWithMetadata

if exist('nrrdLoadWithMetadata','file')
	inf=imnrrdinfo('7x6x3-origin.nrrd');
	% nb don't load with data
	inf2=nrrdLoadWithMetadata('7x6x3-origin.nrrd',0);
	assertEqual(inf.Delta',diag(inf2.spacedirections));
	assertEqual(inf.Origin',inf2.spaceorigin);
end