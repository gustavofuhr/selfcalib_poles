function plot_poles_grid(area, P, step, height, trans_xy)

if ~isempty(trans_xy)
    area(1,:) = area(1,:) + trans_xy(1);
    area(2,:) = area(2,:) + trans_xy(2);
end

% grid_points = [];

for x = area(1,1):step:area(1,2)    
    for y = area(2,1):step:area(2,2)
        pts = [x x; y y; 0.0 height; 1 1];
        pts = P*pts;
        pts(1,:) = pts(1,:)./pts(3,:);
        pts(2,:) = pts(2,:)./pts(3,:);
        plot(pts(1,:), pts(2,:), '-', 'Color', [0.4, 0.4, 0.8], 'LineWidth', 2.0);
        
%         grid_points = [grid_points pts(1:2,1)];
    end
end

% keyboard;
