function [f1,f2,f3,f4,f5] = lab_featuresnew (img) 
% [f1,f2,f3,f4,f5] = lab_features(img)
%
% -- Purpose: Extracts feature vectors 'fx' from an image. This function is
%             called by lab_featuresets, which combines the features
%             into a single vector and normalises it. This vector
%             can then be used for training and testing.
%
% -- <img> a matrix representing the RGB values of the image
% -- <f1>-<f5> features extracted from image
%
% See http://www.generation5.org/content/2004/aisompic.asp for a tutorial
% on a similar technique.
%

    %
    % This function extracts five types of feature from the image
    % You should select which you want to use (see end of function)
    % 
    % RGB Histogram: Divides the RGB colour space up into 
    %                buckets e.g. red (255,0,0), green (0,255,0)
    %                and yellow (255,255,0). The image is iterated
    %                and each pixel's proximity to each bucket
    %                is measured. If for example the pixel is 
    %                very red, then the red bucket has its count
    %                incremented. Essentially this provides a 
    %                histogram detailing the colour of the image.
    %                The feature vector consists of the bucket
    %                counts.
    %
    % RGB Area: Divides the image up into a grid e.g. 3x3. The 
    %           average colour of each grid cell is measured
    %           and used as part of the feature vector. This
    %           can be calculated by simply downsampling (shrinking)
    %           the image.
    %
    % Greyscale Histogram: Like RGB Histogram, but the image is
    %                      converted to greyscale first.
    %
    % Greyscale Area: Like RGB area, but the image is converted to
    %                 greyscale first.
    %
    % Texture: Measures the 'texture' of the image i.e. how much
    %          on average each pixel differs from the rest
    %          of the image.
    %
    
    % TODO: Modify these parameters to your liking
    IMAGE_DOWNSAMPLE_WIDTH = 50;            % Width to downsample the image to when calculating histograms
    IMAGE_DOWNSAMPLE_HEIGHT = 50;           % As above, but height
    GREYSCALE_HISTOGRAM_BUCKET_SIZE = 16;   % Number of buckets to use for greyscale histogram i.e. divides up the space 1-255
    RGB_HISTOGRAM_BUCKET_SIZE = 64;         % Number of buckets to use for RGB histogram i.e. divides up the space 1-255
    GREYSCALE_AREA_GRID_W = 3;              % Width of grid to use for Greyscale Area
    GREYSCALE_AREA_GRID_H = 3;              % As above but height
    RGB_AREA_GRID_W = 4;                    % Width of grid to use for RGB area
    RGB_AREA_GRID_H = 4;                    % As above but height
    
    f1=[];
    f2=[];
    f3=[];
    f4=[];
    f5=[];
    
    % RGB
    imgDownSampled = lab_downsample(img, IMAGE_DOWNSAMPLE_WIDTH, IMAGE_DOWNSAMPLE_HEIGHT);
    % grey
    imgDownSampledGrey=lab_rgb2gray(imgDownSampled);

    
    %
    % RGB Histogram 
    %
    buch = RGB_HISTOGRAM_BUCKET_SIZE;
    bin = floor(255/buch) + 1;
    fHistogramRGB = zeros([bin bin bin]);
    for y = 1:size(imgDownSampled,1)
        for x = 1:size(imgDownSampled,2)
            pixel = double(reshape(imgDownSampled(y,x,:),[1 3]));
            pixel = floor(pixel/buch)+1;
            fHistogramRGB(pixel(1),pixel(2),pixel(3)) = fHistogramRGB(pixel(1),pixel(2),pixel(3))+1;
        end
    end
    fHistogramRGB1 = [];
    for y = 1:size(fHistogramRGB,1)
        for x = 1:size(fHistogramRGB,2)
            for z = 1:size(fHistogramRGB,3)
                fHistogramRGB1 = [fHistogramRGB1,fHistogramRGB(y,x,z)];
            end
        end
    end
    %
    % RGB Area
    %
    imgAreaRGB = lab_downsample(imgDownSampled, RGB_AREA_GRID_W, RGB_AREA_GRID_H);
    fAreaRGB = [];
    for y=1:size(imgAreaRGB, 1)
        for x=1:size(imgAreaRGB, 2)
            fAreaRGB = [fAreaRGB, imgAreaRGB(y,x,1)]; 
        end
    end
    
    %
    % Greyscale Histogram
    %
    
    % Build buckets
    bh = GREYSCALE_HISTOGRAM_BUCKET_SIZE;
    bl = 0;
    gshBuckets = [];
    while (bl < 255)
        gshBuckets = [gshBuckets; [bl, bh]];
        bl = bh;
        bh = bh + GREYSCALE_HISTOGRAM_BUCKET_SIZE;
    end
    
    % Place each pixel in a bucket
    fHistogramGrey=zeros(1, size(gshBuckets, 1)); 
    for y=1:size(imgDownSampledGrey,1)             %row
        for x=1:size(imgDownSampledGrey,2)         %column
            pixel = imgDownSampledGrey(y, x);
            for bucketIndex=1:size(gshBuckets,1)   
                if (pixel >= gshBuckets(bucketIndex, 1) && pixel < gshBuckets(bucketIndex, 2)) 
                    fHistogramGrey(bucketIndex) = fHistogramGrey(bucketIndex) + 1;
                    break;
                end
            end        
        end
    end
    
    %
    % Greyscale Area
    %
    imgAreaGrey = lab_downsample(imgDownSampledGrey, GREYSCALE_AREA_GRID_W, GREYSCALE_AREA_GRID_H);
    fAreaGrey = [];
    for y=1:size(imgAreaGrey, 1)
        for x=1:size(imgAreaGrey, 2)
            fAreaGrey = [fAreaGrey, imgAreaGrey(y,x,1)]; 
        end
    end
  
    %
    % Texture 
    %
    %     for Texture, all i did was use a simple algorithm to determine how much a pixel 
    %         differed from its neighbors.if the pixel was mostly like its neighbors, 
    %         then the image had low texture. 
    %         if the pixel was alot different than its neighbors, 
    %             then texture was high, and the image was probably noisy
    texture = 0;
    avgPixelGrey = mean(mean(imgDownSampledGrey));
    avgPixelGreyMat = repmat(avgPixelGrey, IMAGE_DOWNSAMPLE_WIDTH, IMAGE_DOWNSAMPLE_HEIGHT);
    fTexture = mean(mean(avgPixelGreyMat - imgDownSampledGrey)); 

    %
    % Return features
    %
               
    f1 = fAreaGrey;
    f2 = fTexture;
    f3 = fHistogramGrey;
    f4 = fHistogramRGB1;
    f5 = fAreaRGB;
    