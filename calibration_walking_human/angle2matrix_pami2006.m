function m = angle2matrix_pami2006(pan,tilt,roll)

% phi, theta, psi en radian

% convention xyz
    % par colonne
% m(1,1) =  cos(theta)*cos(psi);
% m(2,1) =  cos(theta)*sin(psi);
% m(3,1) = -sin(theta);
% 
% m(1,2) = -cos(phi)*sin(psi) + sin(phi)*sin(theta)*cos(psi);
% m(2,2) =  cos(phi)*cos(psi) + sin(phi)*sin(theta)*sin(psi);
% m(3,2) =  sin(phi)*cos(theta);
% 
% m(1,3) =  sin(phi)*sin(psi) + cos(phi)*sin(theta)*cos(psi);
% m(2,3) = -sin(phi)*cos(psi) + cos(phi)*sin(theta)*sin(psi);
% m(3,3) =  cos(phi)*cos(theta);

Rx = [  1   0           0       ; ...
        0 cos(tilt) -sin(tilt)    ; ...
        0 sin(tilt)  cos(tilt)    ];

Ry = [  cos(pan)  0   sin(pan)  ; ...
            0       1       0       ; ...
       -sin(pan)  0   cos(pan)  ];

Rz = [  cos(roll) -sin(roll)  0   ; ...
        sin(roll)  cos(roll)  0   ; ...
            0       0       1   ];
        
m = Rz*Rx*Ry;
        