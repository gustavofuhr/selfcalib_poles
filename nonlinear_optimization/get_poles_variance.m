function variance = get_poles_variance(feet_points, options)

% first, use the GT homography to convert the points to world coordinates
P = options.P_gt;
H = [P(:, 1:2) P(:, 4)];

w_feet_points = ics2wcs_H([feet_points; ones(1, size(feet_points,2))], H);

mean_point = mean(w_feet_points, 2);
dist = arrayfun(@(idx) norm(w_feet_points(:,idx) - mean_point), 1:size(w_feet_points,2));

variance = sum(dist.^2)/size(w_feet_points,2);

% % step_w = (options.poles_region(1,2) - options.poles_region(1,1))/10.0;
% % step_h = (options.poles_region(2,2) - options.poles_region(2,1))/10.0;
% % 
% % 
% % % plot(w_feet_points(1,:), w_feet_points(2,:), '.r'); hold on;
% % 
% % n_points = [];
% % for x = options.poles_region(1,1):step_w:options.poles_region(1,2)
% %     for y = options.poles_region(2,1):step_h:options.poles_region(2,2)
% %         % see the region
% % %         plot([x x+step_w x+step_w x x], [y y y+step_h y+step_h y], '-b');
% %         n = get_n_points_inside_square(w_feet_points, x, x+step_w, y, y+step_h);
% %         n_points = [n_points n];
% %     end
% % end
% % 
% % variance = std(n_points(n_points > 0));
% % 
% % 
% % 
% % function n = get_n_points_inside_square(points, x_min, x_max, y_min, y_max)
% % 
% % in_points = inpolygon(points(1,:),points(2,:), ...
% %                     [x_min x_max x_max x_min x_min], ...
% %                     [y_min y_min y_max y_max y_min]);
% %                 
% % n = sum(in_points);