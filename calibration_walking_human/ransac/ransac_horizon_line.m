%% This is an example usage of the RANSAC algorithm. We try to find the
%% best line though a set of data points which have many outliers.

close all;
clear;
clc;

addpath('../');

load('../qt_pts_all.mat');
f_pts = double(f_pts);
h_pts = double(h_pts);

options.image_suf         = 'D:/datasets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
% options.image_suf         = '/home/gfuhr/phd/datasets/pets/Crowd_PETS09/S2/L1/Time_12-34/View_001/frame_';
options.d_mask            = 4;
options.file_ext          = 'jpg';
options.ith_frame         = 180;
im_frame = get_frame(options, options.ith_frame);
% imshow(im_frame); hold on;

pts_h_line = [];
for i=1:size(f_pts,2)
    for j = i+1:size(f_pts, 2)
        % first compute the head point using the ground truth calibration
        im_f_point1 = [f_pts(1,i); f_pts(2,i); 1.0];        
        im_h_point1 = [h_pts(1,i); h_pts(2,i); 1.0];
                
        im_f_point2 = [f_pts(1,j); f_pts(2,j); 1.0];
        im_h_point2 = [h_pts(1,j); h_pts(2,j); 1.0];
        
%         plot([im_f_point1(1), im_h_point1(1)], [im_f_point1(2), im_h_point1(2)], '-r', 'LineWidth', 2.0);
%         plot([im_f_point2(1), im_h_point2(1)], [im_f_point2(2), im_h_point2(2)], '-b', 'LineWidth', 2.0);
        
        l1 = cross(im_h_point1, im_h_point2);
        l2 = cross(im_f_point1, im_f_point2);
        
        hpt = cross(l1, l2);
        if hpt(3) ~= 0
            hpt(1) = hpt(1)/hpt(3); hpt(2) = hpt(2)/hpt(3); hpt = hpt(1:2);
            pts_h_line = [pts_h_line hpt];
        
            
        end
%         pause;
    end
end


[p] = LSE_line(pts_h_line)

num_points = length(pts_h_line);

%make half of the points random
points = pts_h_line';
plot(points(:,1), points(:,2), 'xr', 'MarkerSize', 10.0); hold on;
axis equal;
% get min and max x from the axis
[xs] = xlim;
[m,b] = abc_line2mb(p);
y1 = m*xs(1) + b;
y2 = m*xs(2) + b;

plot([xs], [y1, y2], '-b');
InlierThresh = 5;

Trials = 100;
MaxInliers = 0; %initialization value
WinningLineParams = [0 0 0];%initialization value

for iter = 1:Trials
	CurrentInliers = [];
	inliers = 0;
	rand_num = floor(rand(1,2) * num_points); %randomly choose one of the points
	rand_num( rand_num == 0 ) = 1; %there is no point 0
    
    %calculate the line between the two points
	P1 = points(rand_num(1),:);
	P2 = points(rand_num(2),:);
	[A B C] = FindLine(P1, P2);

    %find the distance from every point to the line
	for counter = 1:num_points
		d = DistancePointToLine(A,B,C,points(counter,:));
        %label the point an inlier if its distance to the line is below the threshold
		if d < InlierThresh
			inliers = inliers + 1;
			CurrentInliers(inliers) = counter; %keep track of which points are inliers on wrt this line
		end
	end

	%if this is the best line so far, update the winning line
	if inliers > MaxInliers
		WinningLineParams = [A B C];
		MaxInliers = inliers;
		GoodInliers = CurrentInliers;
		GoodPoints = rand_num;
	end

end

A = WinningLineParams(1);
B = WinningLineParams(2);
C = WinningLineParams(3);
[m b] = ABC2mb(A, B, C);

[xs] = xlim;
y1 = m*xs(1) + b;
y2 = m*xs(2) + b;

plot([xs], [y1, y2], '-r');
plot(points(GoodInliers,1), points(GoodInliers,2), 'go');

% dy = -A;
% dx = B;
% 
% if WinningLineParams == [0 0 0]
% 	disp('No Line Found')
% else
% 	l = createLine(0,b,dx,dy);
% 	drawLine(l,'r')	
% end