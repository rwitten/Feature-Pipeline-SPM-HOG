function [ pyramid_all ] = BuildPyramid( imageFileList, params, isTrain)
%function [ pyramid_all ] = BuildPyramid( imageFileList, imageBaseDir, dataBaseDir, dictionarySize, numTextonImages, pyramidLevels )
%
%Complete all steps necessary to build a spatial pyramid based
% on sift features.
%
% To build the pyramid this function first extracts the sift descriptors
%  for each image. It then calculates the centers of the bins for the
%  dictionary. Each sift descriptor is given a texton label corresponding
%  to the appropriate dictionary bin. Finally the spatial pyramid
%  is generated from these label lists.
%
%
% imageFileList: cell of file paths
% imageBaseDir: the base directory for the image files
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files
% maxImageSize: the max image size. If the image is larger it will be
%  resampeled.
% dictionarySize: size of descriptor dictionary (200 has been found to be a
%  good size)
% numTextonImages: number of images to be used to create the histogram bins
% pyramidLevels: number of levels of the pyramid to build
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.
%
% Example:
% BuildPyramid(file_list, image_dir, data_dir);
%  Builds the spacial pyramid descriptor for all files in the file_list and
%  stores the data generated in data_dir. Dictionary size is set to 200,
%  50 texton images are used to build the historgram bins, 4 pyramid
%  levels are generated, and the image size has a maximum of 1000 pixels in
%  either the x or y direction.

imageBaseDir = params.image_dir;
dataBaseDir = params.data_dir;
maxImageSize = params.max_image_size;
dictionarySize = params.dictionary_size;
pyramidLevels = params.pyramid_levels;
numTextonImages=params.num_texton_images;
maxPooling = params.max_pooling;
canSkip = params.can_skip;
numNeighbors = params.numNeighbors;

% %% parameters for feature extraction (see GenerateSiftDescriptors)
% if(nargin<4)
%     maxImageSize = 1000
% end
% 
% gridSpacing = 8
% patchSize = 16
% 
% 
% %% parameters for obtaining texton dictionary (see CalculateDictionary)
% if(nargin<5)
%     dictionarySize = 200
% end
% 
% if(nargin<6)
%     numTextonImages = 50
% end
% 
% 
% %% parameters for pyramid computation (see CompilePyramid)
% if(nargin<7)
%     pyramidLevels = 4
% end
% 
% %% parameters for all functions
% if(nargin<8)
%     canSkip = 1
% end

%% build the pyramid

pyramid_all = []

for i=1:size(params.features,2),
	GenerateDescriptors( params.features{i}{1}, params.features{i}{2}, imageFileList,params);
	if isTrain
		CalculateDictionary(imageFileList,dataBaseDir,sprintf('_%s.mat',params.features{i}{1}),dictionarySize,numTextonImages,params);
	end
	BuildHistograms(imageFileList,dataBaseDir,sprintf('_%s.mat',params.features{i}{1}),dictionarySize,params);
	pyramid = CompilePyramid(imageFileList,dataBaseDir,sprintf('_texton_ind_%d_%s.mat',dictionarySize,params.features{i}{1}),dictionarySize,pyramidLevels,params.features{i}{1}, params);
	pyramid_all = [pyramid_all, pyramid];
end
size(pyramid_all)
