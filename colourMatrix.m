function [ Result ] = colourMatrix(originalRGB)

%Load in the picture
%originalRGB = imread('N:/Documents/MATLAB/Image Processing/Project/SimulatedImages2/noise_1.png');
%Display original image in a figure
subplot(5,5,1),imshow(originalRGB);
title('original')
%=====================================================================
%Denoise the image
%=====================================================================

%Denosie and display filtered image
h = fspecial('average', 5);
subplot(5,5,2), filteredRGB = imfilter(originalRGB,h);
imshow(filteredRGB);
title('Filtered')

%====================================================================
%Find points of interest in the image
%====================================================================

%Convert the image to HSV in order to easily 
%seperate black from colours using the "V" component
filteredHSV = rgb2hsv(filteredRGB);
Value_Original = filteredHSV(:,:,3);
subplot(5,5,3),imshow(Value_Original);
title('V of HSV');
gray11 = rgb2gray(filteredRGB);

%The value image is then biniazed to leave areas of black (val = 0)
%Or areas of white (val = 1)
Bin_Original = imbinarize(Value_Original,0.5);
subplot(5,5,4),imshow(Bin_Original);
title('Binarised')

%Structuring elements are specified here
se1 = strel('disk', 6);
se2 = strel('disk',6);

%The Binarized image is now dilated to remove unwanted noise, and lines
%Ideally leaving only the circles and bars located in the corner of
%The image
dilate = imdilate(Bin_Original, se1);
subplot(5,5,5),imshow(dilate);
title('Dilated')

%The image is eroded to restore the remaining features to 
%Aprox original size
dilate = imerode(dilate, se2);
subplot(5,5,6),imshow(dilate)
title('Eroded')


%The image is now inverted to leave the bars and circles white as the
%Points of interest
BW = 1 - dilate;
subplot(5,5,7),imshow(BW);
title('Inverted')

%==================================================================
%Transform image
%==================================================================

%Find circle centres
centres = find_circle_centres(BW);

%Transform image to correct dimentions using circle centres and 
%moving them to nearest fixed points  
Corrected_Image = Correct_Image(filteredRGB, BW);
subplot(5,5,8),imshow(Corrected_Image)
title('Corrected')

%==================================================================
%Rotate image
%==================================================================
%First find bars which determine the current orientation of the image
%Take HSV and binirize to create a black and white image showing only
%Control bars and circle
Corrected_Image_HSV = rgb2hsv(Corrected_Image);
subplot(5,5,9),imshow(Corrected_Image_HSV)
V_HSV = Corrected_Image_HSV(:,:,3);
V_HSV_BW = imbinarize(V_HSV,0.08);

%Show result
subplot(5,5,10),imshow(V_HSV)
subplot(5,5,11),imshow(V_HSV_BW)

%Initialise second structure elements 
se3 = strel('square', 4);
se4 = strel('square',4);

%Binirize as before
dilated_HSV = imdilate(V_HSV_BW, se3);
subplot(5,5,12),imshow(dilated_HSV);
dilated_HSV = imerode(dilated_HSV, se4);
subplot(5,5,13),imshow(dilated_HSV)
%Invert image
dilated_HSV = 1- dilated_HSV;
subplot(5,5,14), imshow(dilated_HSV);


%Check top left corner for presence of bar
%Rotate till ber is  in top left corner 
for i = 1:4
    if dilated_HSV(12,100) == 0
        dilated_HSV = imrotate(dilated_HSV, -90);
        Corrected_Image = imrotate(Corrected_Image, -90);
    end
    
end

%Show Result
subplot(5,5,13),imshow(dilated_HSV);
subplot(5,5,14),imshow(Corrected_Image)


%Pass image to do colour classificataion
%Make image lab colourspace
lab = applycform(Corrected_Image, makecform('srgb2lab'));
lab = lab2double(lab);
subplot(5,5,15), imshow(lab), title('Lab image');

%lab = applycform(filteredRGB, makecform('srgb2lab'));
ab = double(lab(:,:,2:3));
a = lab(:,:,2);
b = lab(:,:,3);
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

%Number of colours = white, red, yellow,blue, green
ncolours = 5;

%KMEANS INITALISE CLUSTERS at (in this order) RGBYW
[cluster_idx, cluster_centre] = kmeans(ab,ncolours,'distance','sqEuclidean','start',[74 63; -65 61; 59 -102;-9 67; 0 0]);

%Label each pixel

pixel_labels = reshape(cluster_idx,nrows,ncols);
subplot(5,5,17),imshow(pixel_labels,[]), title('Image cluster index');

segmented_images = cell(1,3);
col_label = repmat(pixel_labels,[1 1 3]);

for k = 1:ncolours
    color = lab;
    color(col_label ~=k) = 0;
    segmented_images{k} = color;
    
end


Red_image = segmented_images{1};
Red_BW = im2bw(Red_image, 0.5);

Green_image = segmented_images{2};
Green_BW = im2bw(Green_image, 0.0000000001);

Blue_image = segmented_images{3};
Blue_BW = im2bw(Blue_image, 0.5);

Yellow_image = segmented_images{4};
Yellow_BW = im2bw(Yellow_image, 0.5);

White_image = segmented_images{5};
White_BW = im2bw(White_image, 0.5);

subplot(5,5,18),imshow(Red_image),title('Red');
subplot(5,5,19),imshow(Green_image),title('Green');
subplot(5,5,20),imshow(Blue_image),title('Blue');
subplot(5,5,21),imshow(Yellow_image),title('Yellow');
subplot(5,5,22),imshow(White_image),title('White');

%Create holder output matrix
Result = cell(4);


for i = 1:4
    for j = 1:4
        
        %Generate coordinates of centre of square to check
        x_coord = (i*100) - 30;
        y_coord = (j*100) - 30;
        
        if Red_BW(x_coord,y_coord) == 1;
            Result(i, j) = cellstr('R');
        
        elseif Green_BW(x_coord,y_coord) == 1
            Result(i, j) = cellstr('G');
        elseif Blue_BW(x_coord,y_coord) == 1
            Result(i, j) = cellstr('B');
        elseif Yellow_BW(x_coord,y_coord) == 1
            Result(i, j) = cellstr('Y');
        else 
            Result(i, j) = cellstr('W');
   
        end
        
    end
    

    
end

Result;

end

