[file, path] = uigetfile({'*.png;*.jpg'}, 'Select an image to convert');
img = im2double(imread(fullfile(path, file)));
height = size(img, 1);
width = size(img, 2);
sampleImg = zeros(height, width);

%% Cortical area (resultant image dimensions)
cortWidth = ceil(width/2); %% left and right brain are separated
cortHeight = height;
newImg = zeros(cortHeight, cortWidth * 2);

%% expCoef determines how exponential distance is represented in the cortex
% larger numbers mean greater area on cortex is mapped to the foveal region
expCoef = 100;

%% compression refers to how much an image should be scaled down
% a compression of 2 will mean that a circle with radius of 1800 px
% occupies a cortical pattern with a width of 900 px. Values < 1 will scale up the image
compression = width / cortWidth; % when resize, can match size of original image

%% toggle drawing after every row is generated
stepDraw = false;

for pixel = 1:size(img, 3)
    imgSlice = img(:, :, pixel);
    newImgSlice = ones(cortHeight, cortWidth * 2);
    
    for pol = 1: cortHeight
        %% Left side of cortical image
        for dist = 1: cortWidth
            radius = (power(expCoef, 1 - dist/cortWidth) - 1) / (expCoef - 1);
            radius = radius * cortWidth * 2 * compression;
            angle = (90 + pol / cortHeight * 180) * pi/180;
            [pixVal, inRange, x, y] = pixelValue(radius, angle, imgSlice, width, height);
            if inRange
                newImgSlice(pol, dist) = pixVal;
                sampleImg(floor(y), floor(x)) = 1;
            end
        end

        %% Right side of cortical image
        for dist = cortWidth + 1: 2 * cortWidth
            radius = (power(expCoef, dist/cortWidth - 1) - 1) / (expCoef - 1);
            radius = radius * cortWidth * 2 * compression;
            angle = (90 - pol / cortHeight * 180) * pi/180;
            [pixVal, inRange, x, y] = pixelValue(radius, angle, imgSlice, width, height);
            if inRange
                newImgSlice(pol, dist) = pixVal;
                sampleImg(floor(y), floor(x)) = 1;
            end
        end

        if stepDraw; imshow(newImgSlice); end
    end
    newImg(:, :, pixel) = newImgSlice;
end
imshow(newImg);
figure();
imshow(sampleImg);

function [pixVal, inRange, x, y] = pixelValue(radius, angle, img, width, height)
    inRange = false;
    pixVal = 0;
    x = width/2 + 0.5 + cos(angle) * radius; 
    y = height/2 + 0.5 + sin(angle) * radius;
    if [x, y, -x, -y] > [1, 1, -width, -height]
        inRange = true;
        [x1, x2, y1, y2] = deal(floor(x), ceil(x), floor(y), ceil(y));
        weights = [x-x1, 1-x+x1, y-y1, 1-y+y1];
        topAvg = img(y1,x1) * weights(1) + img(y1,x2) * weights(2);
        bottomAvg = img(y2,x1) * weights(1) + img(y2,x2) * weights(2);
        pixVal = topAvg * weights(3) + bottomAvg * weights(4);
    end
end