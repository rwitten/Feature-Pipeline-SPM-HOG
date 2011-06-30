function features = hog(I, imageFName, params)
	[hgt wid] = size(I);
	features.hgt = hgt;
	features.wid = wid;
	
	yys = (1+params.hog_size/2):params.hog_spacing:(hgt-params.hog_size/2-1);
	xxs = (1+params.hog_size/2):params.hog_spacing:(wid-params.hog_size/2-1);

	features.x = zeros(length(yys)*length(xxs),1);
	features.y = zeros(length(yys)*length(xxs),1);
	features.data = zeros(length(yys)*length(xxs),81);

	fprintf('HOGing %s number of descriptors %d\n', imageFName, length(features.x));
	for yy_index = 1:length(yys)
		for xx_index = 1:length(xxs)
			yy = yys(yy_index);
			xx = xxs(xx_index);

			patch = I(yy-params.hog_spacing/2:yy+params.hog_spacing/2-1,...
                                xx-params.hog_spacing/2:xx+params.hog_spacing/2-1);
			descriptor = hogOneDescriptor(patch);
			
			index = (yy_index-1)* length(xxs) + (xx_index);
			features.x(index) = xx;
			features.y(index) = yy;
			features.data(index,:) = descriptor';
		end
	end
end
