function [error] = analyse_P(gt_P, P, plot_poles)


load('in/tc_grid_points.mat');

gt_H = [gt_P(:, 1:2) gt_P(:, 4)];
H = [P(:, 1:2) P(:, 4)];

err_angles = zeros(1, length(grid_points));
err_dist   = zeros(1, length(grid_points));
for i = 1:length(grid_points)
    w_feet_gt  = ics2wcs_H([grid_points(:, i); 1.0], gt_H);
    w_head_gt  = [w_feet_gt(1); w_feet_gt(2); 2.0; 1.0];
    im_head_gt = wcs2ics(w_head_gt, gt_P);
    
    w_feet  = ics2wcs_H([grid_points(:, i); 1.0], H);
    w_head  = [w_feet(1); w_feet(2); 2000.0; 1.0];
    im_head = wcs2ics(w_head, P);
    
    err_dist(i) = norm(im_head - im_head_gt);
    
    v1  = im_head_gt - grid_points(:, i);
    v2  = im_head - grid_points(:, i);
    err_angles(i) = real(acos(dot(v1,v2)/ (norm(v1)*norm(v2)) )) ;
%     err_angles(i) = atan2(norm(cross(v1,v2)),dot(v1,v2));
    
    if plot_poles
        plot([grid_points(1,i), im_head_gt(1)], [grid_points(2,i), im_head_gt(2)], '-', 'Color', [0.2 0.8 0.2], 'LineWidth', 2.0);
        plot([grid_points(1,i), im_head(1)], [grid_points(2,i), im_head(2)], '-', 'Color', [0.8 0.2 0.2], 'LineWidth',  2.0);        
    end
        
end
   

error.angle = sum(err_angles);
error.dist  = sum(err_dist);
   