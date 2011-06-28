function [ ] = CalculateDictionary(imageFileList,dataBaseDir,featureSuffix,dictionarySize,numTextonImages,params)
%function [ ] = CalculateDictionary( imageFileList, dataBaseDir, featureSuffix, dictionarySize, numTextonImages, canSkip )
%
%Create the texton dictionary
%
% First, all of the sift descriptors are loaded for a random set of images. The
% size of this set is determined by numTextonImages. Then k-means is run
% on all the descriptors to find N centers, where N is specified by
% dictionarySize.
%
% imageFileList: cell of file paths
% dataBaseDir: the base directory for the data files that are generated
%  by the algorithm. If this dir is the same as imageBaseDir the files
%  will be generated in the same location as the image files.
% featureSuffix: this is the suffix appended to the image file name to
%  denote the data file that contains the feature textons and coordinates. 
%  Its default value is '_sift.mat'.
% dictionarySize: size of descriptor dictionary (200 has been found to be
%  a good size)
% numTextonImages: number of images to be used to create the histogram
%  bins
% canSkip: if true the calculation will be skipped if the appropriate data 
%  file is found in dataBaseDir. This is very useful if you just want to
%  update some of the data or if you've added new images.

fprintf('Building Dictionary\n\n');

%% parameters

reduce_flag = 1;
ndata_max = params.ndata_max;

numTextonImages = size(imageFileList,1);

sprintf('dictionary_%d%s', dictionarySize, featureSuffix)
outFName = fullfile(dataBaseDir, sprintf('dictionary_%d%s', dictionarySize, featureSuffix));

if(size(dir(outFName),1)~=0 && params.can_skip && params.can_skip_calcdict)
    fprintf('Dictionary file %s already exists.\n', outFName);
    return;
end
    
training_indices = randperm(size(imageFileList,1));
training_indices = training_indices(1:numTextonImages);

imageFName = imageFileList{training_indices(1)};
[dirN base] = fileparts(imageFName);
baseFName = fullfile(dirN, base);
inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));
load(inFName, 'features');

feature_length = size(features.data,2);
%% load all SIFT descriptors
sift_all = zeros(params.textons_per_image*numTextonImages, feature_length);
tic;
for f = 1:numTextonImages    
     if toc>1
	fprintf('toc\n');
	tic;
     end
    imageFName = imageFileList{training_indices(f)};
    [dirN base] = fileparts(imageFName);
    baseFName = fullfile(dirN, base);
    inFName = fullfile(dataBaseDir, sprintf('%s%s', baseFName, featureSuffix));

    load(inFName, 'features');
    ndata = size(features.data,1);

    perm = randperm(size(features.data,1));

    numTextons = params.textons_per_image;

    sift_all(1+(f-1)*numTextons:f*numTextons,:) = features.data(perm(1:numTextons),:);
    fprintf('Loaded %s, %d descriptors, %d so far\n', inFName, ndata, numTextons*f);
end

fprintf('\nTotal descriptors loaded: %d\n', size(sift_all,1));

ndata = size(sift_all,1);    
if (reduce_flag > 0) & (ndata > ndata_max)
    fprintf('Reducing to %d descriptors\n', ndata_max);
    p = randperm(ndata);
    sift_all = sift_all(p(1:ndata_max),:);
end
        
%% perform clustering
options = foptions;
options(1) = 1; % display
options(2) = 1;
options(3) = 0.1; % precision
options(5) = 1; % initialization
options(14) = 100; % maximum iterations

centers = zeros(dictionarySize, size(sift_all,2));

%% run kmeans
fprintf('\nRunning k-means\n');
dictionary = sp_kmeans(centers, sift_all, options);

fprintf('Saving texton dictionary\n');
sp_make_dir(outFName);
save(outFName, 'dictionary');

end
