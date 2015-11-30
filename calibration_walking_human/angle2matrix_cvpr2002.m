function R = angle2matrix_cvpr2002(yaw, tilt, pan)

ca = cos(pan);
sa = sin(pan);
cb = cos(tilt);
sb = sin(tilt);
cy = cos(yaw);
sy = sin(yaw);

R = zeros(3,3);
R(1,1) = ca*cy + sa*sb*sy;
R(1,2) = -cb*sy;
R(1,3) = -sa*cy + ca*sb*sy;
R(2,1) = ca*sy - sa*sb*cy;
R(2,2) = cb*cy;
R(2,3) = -sa*sy - ca*sb*cy;
R(3,1) = sa*cb;
R(3,2) = sb;
R(3,3) = ca*cb;