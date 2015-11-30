% 
% This function converts the ROI to int and truncates it with
% respect to the size h x h
% 
% USAGE
%   function new_roi = trunc_roi(roi, h, w)
% 
function new_roi = trunc_roi(roi, h, w)

new_roi = uint16(roi);

new_roi(1) = max([1, new_roi(1)]);
new_roi(3) = min([w, new_roi(3)]);

new_roi(2) = max([1, new_roi(2)]);
new_roi(4) = min([h, new_roi(4)]);