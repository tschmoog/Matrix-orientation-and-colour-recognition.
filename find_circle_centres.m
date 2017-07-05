function [centres] = find_circle_centres(BW_image)
%This function finds the centres of each circle and retursn a matrix
%containing them.

%Identify objects in the image
CC = bwconncomp(BW_image);
%Holder matrix
BW2=zeros(CC.ImageSize);
%Identify information of objects
s = regionprops(CC, 'all');
%Holder Matrix
centres = zeros(4,2);

counter = 1;

for p=1:CC.NumObjects  %loop through each object
    if s(p).Area < 800 && s(p).Area > 150 %Area criterion for spheres
        BW2(CC.PixelIdxList{p}) = 1; %set the image
        centres(counter,1:2) = s(p).Centroid; 
        counter = counter + 1;
    end
end


end

