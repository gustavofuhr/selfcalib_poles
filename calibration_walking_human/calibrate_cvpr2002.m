% image_size = h x w
function [P] = calibrate_cvpr2002(vanishing_point, horizon_line, image_size, head_points, feet_points)

debug = false;

[mhl, bhl] = abc_line2mb(horizon_line);

% the yam is the angle between the horizon_line and the horizontal one
yaw = atan(mhl);

vy = vanishing_point;
% the Vx vanishing point is chosen arbitrarily
vx = [1000; mhl*1000 + bhl];

% know I need to rotate by yaw: vx, vy and the horizon line
% such that the horizon line and the horizontal line are aligned
% I take here that the image origin is 1,1
nvxx = 1 + (vx(1) - 1)*cos(-yaw) - (vx(2) - 1)*sin(-yaw);
nvxy = 1 + (vx(1) - 1)*sin(-yaw) + (vx(2) - 1)*cos(-yaw);
vx = [nvxx; nvxy];

nvyx = 1 + (vy(1) - 1)*cos(-yaw) - (vy(2) - 1)*sin(-yaw);
nvyy = 1 + (vy(1) - 1)*sin(-yaw) + (vy(2) - 1)*cos(-yaw);
vy = [nvyx; nvyy];

p1_hl = [0; bhl]; p2_hl = [1; mhl + bhl];
np1_hlx = 1 + (p1_hl(1) - 1)*cos(-yaw) - (p1_hl(2) - 1)*sin(-yaw);
np1_hly = 1 + (p1_hl(1) - 1)*sin(-yaw) + (p1_hl(2) - 1)*cos(-yaw);
np2_hlx = 1 + (p2_hl(1) - 1)*cos(-yaw) - (p2_hl(2) - 1)*sin(-yaw);
np2_hly = 1 + (p2_hl(1) - 1)*sin(-yaw) + (p2_hl(2) - 1)*cos(-yaw);
n_horizon_line = cross([np1_hlx; np1_hly; 1], [np2_hlx; np2_hly; 1]);
[mhl, bhl] = abc_line2mb(n_horizon_line);
horizon_line = n_horizon_line;

if debug
    plot([-5500; 5500], [mhl*-5500 + bhl; mhl*5500 + bhl], '-b');  hold on;
    plot(vx(1), vx(2), 'xr');
    text(vx(1), vx(2), 'Vx', 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
    plot(vy(1), vy(2), 'xr');
    text(vy(1), vy(2), 'Vy', 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
end

% Approximate the principal point
principal_point = [vy(1); image_size(1)/2.0];

if debug
    plot(principal_point(1), principal_point(2), 'xr');
    text(principal_point(1), principal_point(2), 'P', 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
end

% vz
% define L1 as the line defined by the principal point and vx
% y = m1*x + b1
l1 = cross([principal_point; 1.0], [vx; 1.0]);
% m1 needs to be computed because the cross give us ax + by + c = 0
[m1, b1] = abc_line2mb(l1);
% the line which is orthogonal to L1 and that passes trough vy
% y  = m2*x + b1
% m2 = -m1 because is orthogonal
% y + m1*x = b2
m2 = -1/m1;
b2 = vy(2) - m2*vy(1);
l2 = mb_line2abc(m2, b2);
% finally, vz is the intersection between the horizon_line and l2
vz = cross(horizon_line, l2);
vz = vz(1:2)./repmat(vz(3), [2 1]);

if debug
    plot(vz(1), vz(2), 'xr');
    text(vz(1), vz(2), 'Vz', 'VerticalAlignment','bottom', 'HorizontalAlignment','right');
    plot([vx(1); principal_point(1) - 3000], [vx(1)*m1 + b1; (principal_point(1) - 3000)*m1 + b1], '-g');
    plot([vy(1); vz(1)], [vy(1)*m2 + b2; vz(1)*m2 + b2], '-k');
    axis equal
    set(gca,'YDir','reverse');
    principal_point
    ctriangle = center([vx; 0.0], [vy; 0.0], [vz; 0.0], 'orthocenter')    
end

% For a brief moment I am assuming that the yaw angle is zero
uP = principal_point(1);
vP = principal_point(2);

uVx = vx(1); vVx = vx(2);
uVy = vy(1); vVy = vy(2);
uVz = vz(1); vVz = vz(2);

% compute the temp values
f = sqrt(-(vVx - vP)*(vVy - vP));
tilt = atan((vP - vVx)/f);
% the inverse of cotangent is 2 * Atan(1) - Atan(x)
pan = 2 * atan(1) - atan((uVx - uP)*cos(tilt)/f);

% compute the camera height using the cross ratio invariance
avg_human_height = 1650; % mm
n_poles = size(feet_points, 2);
hcs = [];
for i = 1:n_poles
    f_pt = feet_points(:, i);
    h_pt = head_points(:, i);

    line_vy_f = cross([vy; 1], [f_pt; 1]);
    line_vy_h = cross([vy; 1], [h_pt; 1]);
    if sum(line_vy_f == line_vy_h) == 3 % the 3 points are collinear
        d = cross(line_vy_f, horizon_line);
        d = d(1:2)./repmat(d(3), [2 1]);
    else % not collinear
        d1 = cross(line_vy_f, horizon_line);
        d1 = d1(1:2)./repmat(d1(3), [2 1]);
        d2 = cross(line_vy_h, horizon_line);
        d2 = d2(1:2)./repmat(d2(3), [2 1]);
        d = (d1 + d2)./2.0;
    end
    hc = (avg_human_height/(1 - (norm(h_pt - d)*norm(f_pt - vy))/...
        (norm(f_pt - d)*norm(h_pt - vy))));
    hcs = [hcs hc];
end
Hc = median(hcs);

% now, knowing that the yaw is nonzero, change values
principal_point(1) = uP*cos(yaw) - vP*sin(yaw);
principal_point(2) = uP*sin(yaw) + vP*cos(yaw);

% I can compute the rotation matrix to see the result
R = angle2matrix_cvpr2002(yaw, tilt, pan);

% tx="8.2873214225e+02" ty="-3.1754796051e+03" tz="3.5469298547e+04"

K = [f   0  principal_point(1)  0;...
     0   f  principal_point(2)  0;...
     0   0                   1  0];
 
t = R*[0; -Hc; 0];
% for the poles extracted t = R*[-19000; -Hc; -18000];
% for the GT was a good translation t = R*[-25000; -Hc; -13000];

Rt = [R t; zeros(1,3) 1];

P = K*Rt;

% change two rows of the projection matrix
nP = P;
nP(:,2) = P(:,3);
nP(:,3) = P(:,2);

P = nP;





