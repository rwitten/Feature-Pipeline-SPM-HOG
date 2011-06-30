function features = dsift(I, imageFName, params)
	[positions, descriptors] = vl_dsift(im2single(I),'size',4,'fast','step',4);;
	features.data = double(descriptors')/256;
	features.x = positions(1,:)';
	features.y = positions(2,:)';
	[hgt wid] = size(I);
	features.hgt = hgt;
	features.wid = wid;
	fprintf('DSIFTing %s number of descriptors %d\n', imageFName, length(features.x));
end
