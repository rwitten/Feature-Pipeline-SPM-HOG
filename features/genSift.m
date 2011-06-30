function [features] = genSift(I, imageFName, params, featureType)
	[hgt wid] = size(I);
        features.hgt = hgt;
        features.wid = wid;

	tempfile = ['temp' randseq(20), '.txt'];
	command = sprintf('./colorSift/colorDescriptor %s --output %s --descriptor %s --outputFormat binary', imageFName, tempfile, featureType);

	system(command);
	fprintf('%s\n', command);

	[d,f]=readBinaryDescriptors(tempfile);
	system(sprintf(sprintf('rm %s', tempfile)));

	features.data = d;
	features.x = d(:,1);
	features.y = d(:,2);
end

function [d , f]= readBinaryDescriptors(str)
	fid = fopen(str,'rb');             % Open binary file
	m = char(fread(fid,16,'uint8'));   % header BINDESC1 + datatype
	Z1=fread(fid,4,'uint32');
	elementsPerPoint = Z1(1);
	dimensionCount = Z1(2);
	pointCount = Z1(3);
	bytesPerElement = Z1(4);

	f = my_vec2mat(fread(fid, elementsPerPoint * pointCount, 'double'), elementsPerPoint );
	d = my_vec2mat(fread(fid, dimensionCount * pointCount, 'double'), dimensionCount );
	fclose(fid);
end

function b = my_vec2mat(c, nc)
	rem(nc - rem(numel(c),nc),nc)
	b = reshape([c(:) ; zeros(rem(nc - rem(numel(c),nc),nc),1)],nc,[]).';
end
