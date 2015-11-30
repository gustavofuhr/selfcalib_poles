function [line] = LSE_line(pts)

N_points = length(pts);

xs = pts(1,:);
ys = pts(2,:);


A = [xs(:) ones(N_points, 1)];
b = [ys(:)];

x = inv(A'*A)*A'*b;
m = x(1);
b = x(2);

line = mb_line2abc(m, b);

