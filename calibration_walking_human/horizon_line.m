function [h_line] = horizon_line(head_points, feet_points, poles_ass, options)

debug = false;

if debug
%     figure('Color', 'w');
    n_colors = 20;
    colors = distinguishable_colors(n_colors);
end

pts_h_line = [];
if isempty(poles_ass)
    for i=1:size(feet_points,2)
        for j = i+1:size(feet_points, 2)
            im_f_point1 = [feet_points(1,i); feet_points(2,i); 1.0];
            im_h_point1 = [head_points(1,i); head_points(2,i); 1.0];
            
            im_f_point2 = [feet_points(1,j); feet_points(2,j); 1.0];
            im_h_point2 = [head_points(1,j); head_points(2,j); 1.0];
            
            l1 = cross(im_h_point1, im_h_point2);
            l2 = cross(im_f_point1, im_f_point2);
            
            hpt = cross(l1, l2);
            if hpt(3) ~= 0
                hpt(1) = hpt(1)/hpt(3); hpt(2) = hpt(2)/hpt(3); hpt = hpt(1:2);
                pts_h_line = [pts_h_line hpt];
                
                if debug
                    plot(hpt(1), hpt(2), 'xr', 'MarkerSize', 10.0); hold on;
                end
            end
        end
    end
    
else
    unique_ids = unique(poles_ass);
    for id = unique_ids
        if id ~= -1
            % take the poles of that id
            id_head_points = head_points(:,poles_ass == id);
            id_feet_points = feet_points(:,poles_ass == id);
            
            for i = 1:size(id_head_points, 2)
                for j = i+1:size(id_head_points, 2)
                    im_f_point1 = [id_feet_points(1,i); id_feet_points(2,i); 1.0];
                    im_h_point1 = [id_head_points(1,i); id_head_points(2,i); 1.0];
                    
                    im_f_point2 = [id_feet_points(1,j); id_feet_points(2,j); 1.0];
                    im_h_point2 = [id_head_points(1,j); id_head_points(2,j); 1.0];
                    
                    % first of all, im going to use this pair of points
                    % only if their distance is above a min value
                    min_dist = options.min_distance;
                    mid_pt1 = (im_f_point1 + im_h_point1)./2.0;
                    mid_pt2 = (im_f_point2 + im_h_point2)./2.0;
                    if norm(mid_pt1 - mid_pt2) >= min_dist
                        l1 = cross(im_h_point1, im_h_point2);
                        l2 = cross(im_f_point1, im_f_point2);
                        
                        hpt = cross(l1, l2);
                        if hpt(3) ~= 0
                            hpt(1) = hpt(1)/hpt(3); hpt(2) = hpt(2)/hpt(3); hpt = hpt(1:2);
                            pts_h_line = [pts_h_line hpt];
                            
                            if debug
                                c = colors(mod(id, n_colors)+1, :);
                                plot(hpt(1), hpt(2), 'x', 'Color', c, 'MarkerSize', 10.0, 'LineWidth', 2.0); hold on;
                            end
                        end
                    end
                end
            end
        end
        
    end
end

fprintf('\nNumber of points to extract the horizon line: %d\n', length(pts_h_line));

[h_line] = ransac_line(pts_h_line, options.ransac_inliner, options.ransac_trials);

% if debug
%     axis equal;
%     % get min and max x from the axis
%     [xs] = xlim;
%     
%     [m,b] = abc_line2mb(h_line);
%     y1 = m*xs(1) + b;
%     y2 = m*xs(2) + b;
    
%     plot([xs], [y1, y2], '-b');
% end
