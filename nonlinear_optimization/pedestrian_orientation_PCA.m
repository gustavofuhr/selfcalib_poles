function [foot_pt, head_pt, qt] = pedestrian_orientation_PCA(bgs_pedestrian)


%% extract the foreground coordinates 
[xx, yy] = meshgrid(1:size(bgs_pedestrian, 2), 1:size(bgs_pedestrian, 1));
fore_x = xx(bgs_pedestrian);
fore_y = yy(bgs_pedestrian);
% figure;
% plot(fore_x, fore_y, '.r'); hold on;
% axis equal;

%% get the PCA to compute the head and foot points using the orientation
% of largest variance
% [pc, ~, scores] = princomp([fore_x fore_y]);
xs = [fore_x fore_y];

N_points = length(xs);
xs = xs - repmat(mean(xs,1), [N_points 1]);

cx = cov(xs);
[pc,d] = eig(cx);
d = diag(d);


x_center = size(bgs_pedestrian, 2)/2.0;
y_center = size(bgs_pedestrian, 1)/2.0;
% the second eigenvector is the most important one.
% quiver(x_center, y_center, pc(1,2)*sqrt(d(2)), pc(2,2)*sqrt(d(2)), 'LineWidth', 2.0, 'AutoScale','off', 'Color', 'b');

% NOTE:
% officially, the head and foot point should be extracted only when
% qt is minimum, but for now I am always trusting on PCA
% the highest eigenvalue is the second one here
qt = d(1)/d(2);
% min_size = 30;
% if length(qt) > min_size
%     %% 
% end    


head_pt = [0; 0];
foot_pt = [0; 0];

x1 = [x_center; y_center; 1];
x2 = [x_center + pc(1,2)*sqrt(d(2)); y_center + pc(2,2)*sqrt(d(2)); 1];
l = cross(x1,x2);
for yi = 1:size(bgs_pedestrian, 1)
    % ax + by + c = 0
	% I know the y want to know the x
    % x = (-b*y -c)/a        
    xi = (-l(2)*yi -l(3))/l(1);
    xi = uint16(xi);
    
    if sum(head_pt == [0; 0]) == 2 && bgs_pedestrian(yi, xi) == 1
        head_pt = [xi; yi];
    elseif bgs_pedestrian(yi, xi) == 1
        foot_pt = [xi; yi];    
    end
    
%     plot(xi, yi, 'xg');
end

% plot([head_pt(1), foot_pt(1)], [head_pt(2), foot_pt(2)], 'ob');

