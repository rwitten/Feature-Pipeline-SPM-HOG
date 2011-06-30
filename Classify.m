function [] = Classify()
	addpath(genpath('vlfeat'));
	vl_setup('noprefix');

	%Initialize parameters of SPM classification
	params = initParams();

	%Build pyramids for each class
	train_labels = [];
	test_labels = [];
	train_filenames = {};
	test_filenames = {};
	for i=1:params.num_classes
	    %Build list of filepaths
	    cur_train_image_dir = strcat(params.image_dir, '/train/',params.class_names{i});
	    cur_test_image_dir = strcat(params.image_dir, '/test/',params.class_names{i});
	    train_fnames = dir(fullfile(cur_train_image_dir, '*.jpg'));
	    test_fnames = dir(fullfile(cur_test_image_dir, '*.jpg'));
	    num_train_files = size(train_fnames,1);
	    num_test_files = size(test_fnames,1);
	    newfilenames = cell(num_train_files,1);
	    for f = 1:num_train_files
		newfilenames{f} =  strcat('train/',params.class_names{i}, '/', train_fnames(f).name);
	    end
	    train_filenames(end + (1:num_train_files)) = newfilenames;
	    train_labels = [train_labels; i*ones(num_train_files,1)];
	    newfilenames = cell(num_test_files,1);
	    for f = 1:num_test_files
		newfilenames{f} =  strcat('test/', params.class_names{i}, '/', test_fnames(f).name);
	    end
	    test_filenames(end + (1:num_test_files)) = newfilenames;
	    test_labels = [test_labels; i*ones(num_test_files,1)];
	end

	if params.baby_test,
		num_train_images=params.baby_test_num_train;
		num_test_images = params.baby_test_num_test;
	else
		num_train_images = length(train_filenames);
	        num_test_images = length(test_filenames);
	end

	RandStream.setDefaultStream(RandStream('mt19937ar','seed',10)); %choose the same files
        choices_train = randperm(length(train_filenames));
	choices_train = choices_train(1:num_train_images);
        choices_test = randperm(length(test_filenames));
	choices_test = choices_test(1:num_test_images);

	RandStream.setDefaultStream(RandStream('mt19937ar','seed',floor(sum(clock)))); %in a different order
	choices_train=choices_train(randperm(length(choices_train)));
        choices_test = choices_test(randperm(length(choices_test)));


        train_filenames = (train_filenames(choices_train(1:num_train_images)))';
        train_labels = train_labels((choices_train(1:num_train_images))');

        test_filenames = (test_filenames(choices_test(1:num_test_images)))';
        test_labels = test_labels(choices_test(1:num_test_images)');
	in_pyramids = BuildPyramid(train_filenames, params,1);
	test_pyramids = BuildPyramid(test_filenames, params,0);


	train_data = in_pyramids;
	test_data = test_pyramids;

	%Train detector
	model = train(train_labels,sparse(train_data));
	fprintf('done training\n');
	%Test detector
	[guesses, accuracy] = predict(test_labels, sparse(test_data), model);
end

function params = initParams()
    load('class_names.mat', 'classes');

    params.image_dir = 'images';
    params.data_dir = 'data';

    params.patch_size = 16;
    params.grid_spacing = 8;

    params.features ={ {'sift', @sift}, {'hog', @hog}, {'rgbSift', @rgbSift}, {'colorSift', @colorSift},{'opponentSift', @opponentSift} };
    params.features = params.features(randperm(length(params.features)));
    params.features ={{'sift', @sift}};

    params.baby_test = 0;
    params.baby_test_num_train = 1500;
    params.baby_test_num_test = 1000;

    params.class_names = classes;
    params.num_classes = length(params.class_names);
    params.max_image_size = 1000;
    params.dictionary_size = 1000;
    params.pyramid_levels = 1;

    params.max_pooling = 1;
    params.sum_norm = 1;
    
    params.can_skip = 1;
    params.can_skip_sift = 1;
    params.can_skip_calcdict= 1;
    params.can_skip_buildhist =1;
    params.can_skip_compilepyramid =1;
  
    params.ndata_max = 50000;
    params.textons_per_image = 50;
    params.num_texton_images = inf;

    params.hog_spacing = 4;
    params.hog_size = 10;
    params.sift_grid_spacing = 8;
    params.sift_patch_size = 16;
    params.percent_train = 0.7;
    %obselete, but kept to keep consistency on filenames
    params.numNeighbors = 1;
end
