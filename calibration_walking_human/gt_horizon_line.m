% this script computes the horizon line using the truth calibration

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


pts_h_line = [];
for i=1:size(f_pts,2)
    for j = i+1:size(f_pts, 2)
        % first compute the head point using the ground truth calibration
        im_f_point1 = [f_pts(1,i); f_pts(2,i); 1.0];        
        w_f_point = ics2wcs_H(im_f_point1, H); w_h_point = [w_f_point(1); w_f_point(2); 2000.0; 1.0];
        im_h_point1 = wcs2ics(w_h_point, P);
                
        im_f_point2 = [f_pts(1,j); f_pts(2,j); 1.0];
        w_f_point = ics2wcs_H(im_f_point2, H); w_h_point = [w_f_point(1); w_f_point(2); 2000.0; 1.0];
        im_h_point2 = wcs2ics(w_h_point, P);
        
        l1 = cross([im_h_point1; 1], [im_h_point2;1]);
        l2 = cross(im_f_point1, im_f_point2);
        
        hpt = cross(l1, l2);
        if hpt(3) ~= 0
            hpt(1) = hpt(1)/hpt(3); hpt(2) = hpt(2)/hpt(3); hpt = hpt(1:2);
            pts_h_line = [pts_h_line hpt];
        
            plot(hpt(1), hpt(2), 'ob', 'MarkerSize', 10.0); hold on;
        end
    end
end

axis equal;
% get min and max x from the axis
[xs] = xlim;
[p] = LSE_line(pts_h_line)

[m,b] = abc_line2mb(p);
y1 = m*xs(1) + b;
y2 = m*xs(2) + b;

plot([xs], [y1, y2], '-b');
