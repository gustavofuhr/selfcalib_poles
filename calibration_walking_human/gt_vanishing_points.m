
% this scipt extracts the vanishing points using the truth calibration,
% usefull to compare to the vanishing extracted from backgrounds.

close all;
clear;
clc;

load('qt_pts_all.mat');
f_pts = double(f_pts);


% get the ground truth calibration
calib_filename = 'gt/pets_view_001.xml';
[K, Rt] = parse_xml_calibration_file(calib_filename);
P = K*Rt;
H = [P(:, 1:2) P(:, 4)];


% compute all agains all vanishing points
all_vpts = [];
for i = 1:size(f_pts, 2)
    for j = i+1:size(f_pts, 2)
        % first compute the head point using the ground truth calibration
        im_f_point = [f_pts(1,i); f_pts(2,i); 1.0];
        w_f_point = ics2wcs_H(im_f_point, H);
        w_h_point = [w_f_point(1); w_f_point(2); 2000.0; 1.0];
        im_h_point = wcs2ics(w_h_point, P);
        l1 = cross([im_h_point;1], [f_pts(:,i);1]);
        
        im_f_point = [f_pts(1,j); f_pts(2,j); 1.0];
        w_f_point = ics2wcs_H(im_f_point, H);
        w_h_point = [w_f_point(1); w_f_point(2); 2000.0; 1.0];
        im_h_point = wcs2ics(w_h_point, P);
        l2 = cross([im_h_point; 1], [f_pts(:,j);1]);
        
        % the point of intersection between these two lines is the
        % vanishing point
        vpt = cross(l1, l2);
        if vpt(3) ~= 0 % == 0 -> parallel lines
            vpt(1) = vpt(1)/vpt(3);
            vpt(2) = vpt(2)/vpt(3);            
            all_vpts = [all_vpts vpt(1:2)];
            % this is will condinned because some lines can be parallel.
            plot(vpt(1), vpt(2), 'xr'); hold on;
        end
    end
end

% show the median of the vanishing points
median_vanishing_point = [median(all_vpts(1,:)); median(all_vpts(2,:))]
plot(median_vanishing_point(1), median_vanishing_point(2), 'ob');

% 
% median_vanishing_point =
% 
%    1.0e+03 *
% 
%     0.5399
%     4.3142

% median_vanishing_point =
% 
%    1.0e+03 *
% 
%     0.5423
%     2.0812

% now, randomilly choose some pars to show if the vanishing point
% are coherent
% n_pairs = 1;
% figure; hold on;
% for i = 1:n_pairs
%     i_first  = unidrnd(size(h_pts, 2));
%     i_second = unidrnd(size(h_pts, 2));
%     
%     if i_first ~= i_second
%         % plots the foot to head lines
%         plot([f_pts(1, i_first) h_pts(1, i_first)], [f_pts(2, i_first) h_pts(2, i_first)], '-r', 'LineWidth', 2.0);
%         plot([f_pts(1, i_second) h_pts(1, i_second)], [f_pts(2, i_second) h_pts(2, i_second)], '-r', 'LineWidth', 2.0);
%     end
% end
