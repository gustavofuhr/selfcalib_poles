function plot_axis(len, H, P, trans_xy)


xo = 0;
yo = 0;
if ~isempty(trans_xy)
    xo = xo + trans_xy(1);
    yo = yo + trans_xy(2);
end


% first the x axis
p_xs = [xo yo 1; xo+len yo 1]';
p_xs = H*p_xs;
p_xs(1,:) = p_xs(1,:)./p_xs(3,:);
p_xs(2,:) = p_xs(2,:)./p_xs(3,:);
plot(p_xs(1,:), p_xs(2,:), '-b', 'LineWidth', 2);

% the y axis
p_ys = [xo yo 1; xo yo+len 1]';
p_ys = H*p_ys;
p_ys(1,:) = p_ys(1,:)./p_ys(3,:);
p_ys(2,:) = p_ys(2,:)./p_ys(3,:);
plot(p_ys(1,:), p_ys(2,:), '-r', 'LineWidth', 2);

% the z axis
p_zs = [xo yo 0 1; xo yo len 1]';
p_zs = P*p_zs;
p_zs(1,:) = p_zs(1,:)./p_zs(3,:);
p_zs(2,:) = p_zs(2,:)./p_zs(3,:);
plot(p_zs(1,:), p_zs(2,:), '-g', 'LineWidth', 2);