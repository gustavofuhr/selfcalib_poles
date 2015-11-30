%
% This function does the conversion between the a*x + b*y + c = 0 parametrization
% of a line to the y = m*x + b way of parametrization
% 
function [m,b] = abc_line2mb(line)

m = -line(1)/line(2);
b = -line(3)/line(2);