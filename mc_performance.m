function [rmsePercentage, elapsedTime] = mc_performance(prevFrame,currentFrame,blockSize,p,searchAlgorithm)
    
    tic; %start timer

    %initialise frame and frame size
    originalPrevFrame = prevFrame;
    originalCurrentFrame = currentFrame;
    greyPrevFrame = double(rgb2gray(originalPrevFrame));
    greyCurrentFrame = double(rgb2gray(originalCurrentFrame));
    [H, W] = size(greyPrevFrame); 
    
    % initialise MSE and motion vector array
    motionVector_x = zeros(H/blockSize, W/blockSize);   % motion vectors (x component)
    motionVector_y = zeros(H/blockSize, W/blockSize);   % motion vectors (y component)
    blockMSE = zeros(H/blockSize, W/blockSize);  % MSE for each block
    
    for blockTopLeftCoordinate_y = 1:blockSize : H-blockSize+1         % block top-left corner y
        for blockTopLeftCoordinate_x = 1 : blockSize:W-blockSize+1     % block top-left corner x
            blockRow = (blockTopLeftCoordinate_y - 1)/blockSize + 1;
            blockColumn = (blockTopLeftCoordinate_x - 1)/blockSize + 1;
            currentBlock = greyCurrentFrame( ...
                blockTopLeftCoordinate_y : blockTopLeftCoordinate_y + blockSize - 1, ...
                blockTopLeftCoordinate_x : blockTopLeftCoordinate_x + blockSize - 1 ...
                );
    
            bestError = inf;
            best_dx = 0;
            best_dy = 0;
            % Define search window boundaries (clamped to frame size)
            y_min = max(1, blockTopLeftCoordinate_y - p);
            y_max = min(H - blockSize + 1, blockTopLeftCoordinate_y + p);
            x_min = max(1, blockTopLeftCoordinate_x - p);
            x_max = min(W - blockSize + 1, blockTopLeftCoordinate_x + p);

            % Exhaustive search
            if searchAlgorithm == 1
                for yy = y_min:y_max
                    for xx = x_min:x_max
                        referenceBlock = greyPrevFrame(yy:yy+blockSize-1, xx:xx+blockSize-1);
                        % Compute mean squared error (MSE) for this candidate
                        greyPredictionError = currentBlock - referenceBlock;
                        MSE = mean(greyPredictionError(:).^2);
                        if MSE < bestError
                            bestError = MSE;
                            best_dy = yy - blockTopLeftCoordinate_y;   % displacement in y
                            best_dx = xx - blockTopLeftCoordinate_x;   % displacement in x
                        end
                    end
                end
            % Logarithmic search
            elseif searchAlgorithm == 2
                stepSize = 2 ^ floor(log2(p)); % initial step size as power of 2
                stepSize = floor(stepSize / 2); % start with p/2
                center_y = blockTopLeftCoordinate_y;
                center_x = blockTopLeftCoordinate_x;

                while true
                    candidates = [
                        -stepSize,-stepSize;  -stepSize,0;  -stepSize,stepSize;
                        0,-stepSize;             0, 0;              0,stepSize;
                        stepSize,-stepSize;   stepSize,0;   stepSize,stepSize];
                    
                    for k = 1:size(candidates, 1)
                        dy_cand = candidates(k, 1);
                        dx_cand = candidates(k, 2);
                        cand_y = center_y + dy_cand;
                        cand_x = center_x + dx_cand;
            
                        if cand_y >= y_min && cand_x >= x_min && ...
                           cand_y <= y_max && cand_x <= x_max
            
                            referenceBlock = greyPrevFrame( ...
                                cand_y : cand_y + blockSize-1, ...
                                cand_x : cand_x + blockSize-1 ...
                                );
                            
                            greyPredictionError = currentBlock - referenceBlock;
                            MSE = mean(greyPredictionError(:).^2);
            
                            if MSE < bestError
                                bestError = MSE;
                                best_dy = cand_y - blockTopLeftCoordinate_y;
                                best_dx = cand_x - blockTopLeftCoordinate_x;
                            end
                        end
                    end

                    if stepSize <= 1
                        prevCenter_y = center_y;
                        prevCenter_x = center_x;

                        center_y = best_dy + blockTopLeftCoordinate_y;  % move search center to better match
                        center_x = best_dx + blockTopLeftCoordinate_x;

                        if prevCenter_y == center_y && prevCenter_x == center_x  % end the search if center is not changed
                            break;
                        end

                    else
                        center_y = best_dy + blockTopLeftCoordinate_y;  % move search center to better match
                        center_x = best_dx + blockTopLeftCoordinate_x;
                    end

                    if stepSize > 1
                        stepSize = stepSize / 2;
                    end
                end
                
            end

            % Store the best motion vector and error for this block
            motionVector_y(blockRow, blockColumn) = best_dy;
            motionVector_x(blockRow, blockColumn) = best_dx;
            blockMSE(blockRow, blockColumn) = bestError;
        end
    end

    elapsedTime = toc;    % End timer and return time in seconds
    
    % Calculate Power of Prediction Error 
    predictionSquaredError = 0;
    for blockTopLeftCoordinate_y = 1 : blockSize : H
        for blockTopLeftCoordinate_x = 1 : blockSize : W
    
            % get the 2D index of current block
            blockRow = ((blockTopLeftCoordinate_y-1) / blockSize) + 1;
            blockColumn = ((blockTopLeftCoordinate_x-1) / blockSize) + 1;
    
            % retrieve its corresponding motion vector
            dy = motionVector_y(blockRow, blockColumn);
            dx = motionVector_x(blockRow, blockColumn);
    
            % determine reference block top left coordinate using motion vector
            referenceBlockTopLeftCoordinate_y = blockTopLeftCoordinate_y + dy;
            referenceBlockTopLeftCoordinate_x = blockTopLeftCoordinate_x + dx;
    
            % obtain predicted block from previous frame
            predictedBlock = double( ...
                                originalPrevFrame(...
                                    referenceBlockTopLeftCoordinate_y : referenceBlockTopLeftCoordinate_y + blockSize-1, ...
                                    referenceBlockTopLeftCoordinate_x : referenceBlockTopLeftCoordinate_x + blockSize-1, ...
                                    : ...
                                )...
                            );
    
            % obtain actual block from current frame
            actualBlock = double( ...
                            originalCurrentFrame( ...
                                blockTopLeftCoordinate_y : blockTopLeftCoordinate_y + blockSize-1, ...
                                blockTopLeftCoordinate_x : blockTopLeftCoordinate_x + blockSize-1, ...
                                : ...
                            ) ...
                         );
    
            % calculate and accumulate power of prediction error
            errorBlock = predictedBlock - actualBlock;
            predictionSquaredError = predictionSquaredError + sum(errorBlock(:).^2);
        end
    end
    
    % average prediction error power per pixel
    predictionMSE = predictionSquaredError / (H * W * 3);
    predictionRMSE = sqrt(predictionMSE);
    rmsePercentage = predictionRMSE/(255)*100;
end