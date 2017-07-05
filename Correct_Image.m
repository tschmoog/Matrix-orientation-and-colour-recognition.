function [Corrected_Image] = Correct_Image(Input_Image, BW_Image)
%Takes in an input image and the image conatining only the circles nad
%rectangles and uses that information to correct the image. 


%FixedPoints can be arbitrarily set
fixedPoints = [16.2500000000000,15.2499999999999;16.7499999999999,425.250000000000; 425.250000000000,17.2500000000000; 425.750000000000,425.250000000000];

%Moving points must be found using method
centres = find_circle_centres(BW_Image);

%Align each moving point to its nearest fixed point

[D,I] = pdist2(fixedPoints,centres,'euclidean','Smallest',3);

k = I(1,:);
k2 = I(2,:);
k3 = I(3,:);
%Check for repeated values in K
unq = unique(k);
size_unq = length(unq(1,:));
size_k = length(k(1,:));

%If unq is smaller we have at least two points nearer to one point than
%another and therefore assigned to the same fixed point.
%This for loops assigns next nearest point to these instances
if length(unq(1,:)) < 4
    for i = 1:3
        if k(i) == k(i+1)
            %Find out which is larger and assign it to second nearest point
            dist1 = D(1,i);
            dist2 = D(2,i);
            if dist1 < dist2
                k(i+1) = k2(i+1);
            else
                k(i) = k2(i);
            end
            
        end
        unq = unique(k);
    end
end

%Second check, same as first but checking two elements ahead of 1

if length(unq(1,:)) < 4
    for i = 1:2
        if k(i) == k(i+2)
            %Find out which is larger and assign it to third nearest point
            dist2 = D(2,i);
            dist3 = D(3,i);
            if dist2 < dist3
                k(i+2) = k3(i+2);
            else
                k(i) = k3(i);
            end
            
        end
        unq = unique(k);
    end
end

%Following used for debudding ensuring the above loops work correctly
k_new = k;
size_unq = length(unq(1,:));
size_k = length(k(1,:));

%Assign moving points in order to their respective centres
movingPoints = zeros(4,2);
for i = 1:4 
    j = k(i);
    movingPoints(i,:) = centres(j,:);
end

% Now make the project transform matrix
tform = fitgeotrans(movingPoints,fixedPoints,'projective');

%Save R as a variable
R=imref2d(size(BW_Image));
Corrected_Image = imwarp(Input_Image,tform,'OutputView',R);




end

