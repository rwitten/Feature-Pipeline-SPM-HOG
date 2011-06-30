function features = sift(I, imageFName, params)
    [hgt wid] = size(I);
    patchSize = params.patch_size;
    gridSpacing = params.grid_spacing;

    %% make grid (coordinates of upper left patch corners)
    remX = mod(wid-patchSize,gridSpacing);
    offsetX = floor(remX/2)+1;
    remY = mod(hgt-patchSize,gridSpacing);
    offsetY = floor(remY/2)+1;

    [gridX,gridY] = meshgrid(offsetX:gridSpacing:wid-patchSize+1, offsetY:gridSpacing:hgt-patchSize+1);

    fprintf('Processing (sift) %s: wid %d, hgt %d, grid size: %d x %d, %d patches\n', ...
             imageFName, wid, hgt, size(gridX,2), size(gridX,1), numel(gridX));

    %% find SIFT descriptors
    siftArr = sp_find_sift_grid(I, gridX, gridY, patchSize, 0.8);
    siftArr = sp_normalize_sift(siftArr);

    features.data = siftArr;
    features.x = gridX(:) + patchSize/2 - 0.5;
    features.y = gridY(:) + patchSize/2 - 0.5;

    features.wid = wid;
    features.hgt = hgt;
end
