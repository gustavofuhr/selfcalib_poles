% image_size = h x w
function [P] = calibrate_pami2006(vanishing_point, horizon_line, image_size, feet_point, head_point)

% I am assuming here that the yam angle is zero

% from one vanishing point I need to compute the other ones

principal_point = [vanishing_point(1); image_size(1)/2.0];

% the Vx vanishing point is chosen arbitrarily
[mhl, bhl] = abc_line2mb(horizon_line);
vx = [principal_point(1)+400; mhl*(principal_point(1)+400) + bhl];
vy = vanishing_point;

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
m2 = -m1;
b2 = vy(2) + m1*vy(1);
l2 = mb_line2abc(m2, b2);
% finally, vz is the intersection between the horizon_line and l2
vz = cross(horizon_line, l2);
vz = vz(1:2)./repmat(vz(3), [2 1]);

% debug
% plot([-5500; 5500], [mhl*-5500 + bhl; mhl*5500 + bhl], '-b'); hold on;
% plot(vx(1), vx(2), 'or');
% plot(vz(1), vz(2), 'xr');
% plot(vy(1), vy(2), '^r');
% plot(principal_point(1), principal_point(2), '^b');
% plot([vx(1); principal_point(1) - 3000], [vx(1)*m1 + b1; (principal_point(1) - 3000)*m1 + b1], '-g');
% plot([vy(1); vz(1)], [vy(1)*m2 + b2; vz(1)*m2 + b2], '-k');
% center_triang = center([vx; 0.0], [vy; 0.0], [vz; 0.0], 'orthocenter')
% principal_point
% plot(center_triang(1), center_triang(2), 'xb');
% axis equal
% set(gca,'YDir','reverse');

uP = principal_point(1);
vP = principal_point(2);

uVx = vx(1); vVx = vx(2);
uVy = vy(1); vVy = vy(2);
uVz = vz(1); vVz = vz(2);


roll  = atan((uVy - uP)/(vVy - vP));
sqr_f = (sin(roll)*(uVx - uP) + cos(roll)*(vVx - vP))*(sin(roll)*(uP - uVy)+cos(roll)*(vP - vVy));
f = sqrt(sqr_f);
tilt = atan((sin(roll)*(uVx - uP) + cos(roll)*(vVx - vP))/f);
pan = atan(f/(cos(tilt)*(cos(roll)*(uVx - uP) - sin(roll)*(vVx - vP))));

% I can compute the rotation matrix to see the result
R = angle2matrix_pami2006(pan, tilt, roll);

% compute the camera height using the cross ratio invariance
line_vy_f = cross([vy; 1], [feet_point; 1]);
line_vy_h = cross([vy; 1], [head_point; 1]);
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

height_human = 2000; % mm
Hc = (height_human/(1 - (norm(head_point - d)*norm(feet_point - vy))/...
    (norm(feet_point - d)*norm(head_point - vy))));

t = zeros(3,1);
t(2) = -Hc;
% In order to obtain the other two translations, we define an origin
% in the world, we define as the feet point
uO = feet_point(1);
vO = feet_point(2);
ts = inv([(uO - uP)*R(3,1) - f*R(1,1), (uO - uP)*R(3,3) - f*R(1,3); ...
          (vO - vP)*R(3,1) - f*R(2,1), (vO - vP)*R(3,3) - f*R(2,3)]);
ts = ts*[(uO - uP)*R(3,2) - f*R(1,2); (vO - vP)*R(3,2) - f*R(2,2)];
t(1) = ts(1);
t(3) = ts(2);

K = [f   0  uP;...
     0   f  vP;...
     0   0   1];
    
P = [K zeros(3,1)]*[R, -R*t; zeros(1,3) 1];






