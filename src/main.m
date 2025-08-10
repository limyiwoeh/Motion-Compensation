% read frames
vidObj = VideoReader("hotairballoon_2160_3840_30fps.mp4");
frames = read(vidObj,[100 101]);
whos frames
prevFrame = frames(:,:,:,1);
currentFrame = frames(:,:,:,2);

% mc parameter
searchAlgorithm = 2;
if searchAlgorithm == 1
    blockSize = 2:4;
    blockSize = 2.^blockSize;
    p = 0:16;
elseif searchAlgorithm == 2
    blockSize = 1:4;
    blockSize = 2.^blockSize;
    p = 0:10;
    p = 2.^p;
end

% mc performance array
elapsedTimeArray = zeros(length(blockSize),length(p));
rmsePercentageArray = zeros(length(blockSize),length(p));

% call mc_performance function
for i = 1:length(blockSize)
    for j = 1:length(p)
        [rmsePercentage, elapsedTime] = mc_performance(prevFrame,currentFrame,blockSize(i),p(j),searchAlgorithm);
        
        fprintf("Block size: %d\n", blockSize(i))
        fprintf("Search range (pixel): %d\n", p(j))
        if searchAlgorithm == 1
            fprintf("Search algorithm: Exhaustive search\n")
        elseif searchAlgorithm == 2
            fprintf("Search algorithm: Logarithmic search\n")
        end
        fprintf('%% of Prediction RMSE Relative to Maximum Error: %.4f\n', rmsePercentage);
        rmsePercentageArray(i, j) = rmsePercentage;
        fprintf('Elapsed time: %.4f seconds\n\n', elapsedTime);
        elapsedTimeArray(i, j) = elapsedTime;
    end
end


%% Plot
[blockSizeAxis, pAxis] = meshgrid(blockSize, p);

if searchAlgorithm == 1
    [blockSizeAxis, pAxis] = meshgrid([4,8,16],0:16);
elseif searchAlgorithm == 2
    [blockSizeAxis, pAxis] = meshgrid([2,4,8,16],[0,2,4,8,16,32,64,128,256,512,1024]);
end

elapsedTimeArray = elapsedTimeArray';
rmsePercentageArray = rmsePercentageArray';

if searchAlgorithm == 1
    figure(1)
    t = sgtitle("Exhaustive Search");
    t.FontWeight = 'bold';

    %subplot 1
    subplot(2,1,1)
    % stem3(blockSizeAxis, pAxis, elapsedTimeArray, 'filled');
    surf(blockSizeAxis, pAxis, elapsedTimeArray); 
    shading interp;
    colorbar;
    colormap jet;
    title("Elapsed time against block size and search range")
    xlabel("Block Size (Pixel)")
    ylabel("Search Range (Pixel)")
    zlabel("Elapsed Time (s)")

    %subplot 2
    subplot(2,1,2)
    % stem3(blockSizeAxis, pAxis, rmsePercentageArray, 'filled');
    surf(blockSizeAxis, pAxis, rmsePercentageArray); 
    shading interp;
    colorbar;
    colormap jet;
    title("% Error against block size and search range")
    xlabel("Block Size (Pixel)")
    ylabel("Search Range (Pixel)")
    zlabel("% of Prediction RMSE Relative to Maximum Error")

elseif searchAlgorithm == 2
    figure(2)
    t = sgtitle("Logarithimic Search");
    t.FontWeight = 'bold';

    % subplot 1
    subplot(2,1,1)
    % stem3(blockSizeAxis, pAxis, elapsedTimeArray, "filled");
    surf(blockSizeAxis, pAxis, elapsedTimeArray); 
    shading interp;
    colorbar;
    colormap jet;
    title("Elapsed time against block size and search range")
    xlabel("Block Size (Pixel)")
    ylabel("Search Range (Pixel)")
    zlabel("Elapsed Time (s)")

    %subplot 2
    subplot(2,1,2)
    % stem3(blockSizeAxis, pAxis, rmsePercentageArray, "filled");
    surf(blockSizeAxis, pAxis, rmsePercentageArray); 
    shading interp;
    colorbar;
    colormap jet;
    title("% Error against block size and search range")
    xlabel("Block Size (Pixel)")
    ylabel("Search Range (Pixel)")
    zlabel("% of Prediction RMSE Relative to Maximum Error")

end

