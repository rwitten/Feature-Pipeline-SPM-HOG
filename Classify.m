function [] = Classify()
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
	
	train_filenames = train_filenames';
	test_filenames = test_filenames';
	in_pyramids = BuildPyramid(train_filenames, params,1);
	test_pyramids = BuildPyramid(test_filenames, params,0);


	train_data = in_pyramids;
	test_data = test_pyramids;

	%Train detector
	model = train(train_labels,sparse(train_data));

	%Test detector
	[guesses, accuracy] = predict(test_labels, sparse(test_data), model);
	accuracy %this is correct since we modified dataset to have same size
         %for each class
end

function params = initParams()
    load('class_names.mat', 'classes');

    params.image_dir = 'images';
    params.data_dir = 'data';

    params.useNaiveNN = 1;

    params.cluster_kernel=0;
    params.kernel_size = 1000;

    params.class_names = classes;
    params.num_classes = length(params.class_names);
    params.max_image_size = 1000;
    params.dictionary_size = 200;
    params.num_texton_images = 150;
    params.pyramid_levels = 3;
    params.max_pooling = 1;
    params.sum_norm = 0;
    params.do_llc = 0;
    params.apply_kernel = 1;
    params.can_skip = 1;
    params.can_skip_sift = 1;
    params.can_skip_calcdict = 1;
    params.can_skip_buildhist = 1;
    params.can_skip_compilepyramid = 1;
    params.sumTol = 0;
    params.percent_train = 0.7;
    params.numNeighbors = 1;
    params.usekdtree = 0;
    params.numPassesSift=10;
end
