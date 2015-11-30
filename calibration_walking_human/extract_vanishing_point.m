function [vy] = extract_vanishing_point(head_points, feet_points)

debug = false;

if debug
    figure('Color', 'w');
end

% compute all agains all vanishing points
all_vpts = [];
for i = 1:size(head_points, 2)
    for j = i+1:size(head_points, 2)
        if norm(feet_points(:,i) - feet_points(:,j)) > 20
            % first line
            l1 = cross([head_points(:,i);1], [feet_points(:,i);1]);
            l2 = cross([head_points(:,j);1], [feet_points(:,j);1]);
            
            % the point of intersection between these two lines is the
            % vanishing point
            vpt = cross(l1, l2);
            if vpt(3) ~= 0 % == 0 -> parallel lines
                vpt(1) = vpt(1)/vpt(3);
                vpt(2) = vpt(2)/vpt(3);
                all_vpts = [all_vpts vpt(1:2)];
                
                if debug
                    plot(vpt(1), vpt(2), 'xr');
                    hold on;
                end
            end
        end
    end
end

% show the median of the vanishing point
median_vanishing_point = [median(all_vpts(1,:)); median(all_vpts(2,:))];
vy = [median_vanishing_point(1); median_vanishing_point(2)];

if debug
    plot(vy(1), vy(2), 'ob');
end


