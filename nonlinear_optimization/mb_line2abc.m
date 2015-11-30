%
% This function does the conversion between the y = m*x + b parametrization
% of a line to the a*x + b*y + c = 0 way of parametrization
% 
function [p] = mb_line2abc(m, b)

p = zeros(3,1);

p(1) = m; % a
p(2) = -1.0; % b
p(3) = b; % c
