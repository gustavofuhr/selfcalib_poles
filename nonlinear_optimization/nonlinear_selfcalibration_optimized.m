function [P, final_error] = nonlinear_selfcalibration_optimized(init_P, head_points, feet_points, options, weights)

n_pts = length(head_points);
if isempty(weights)
    weights = 1.0/double(n_pts);
end


alpha = 100; % weight for the angle error
beta  = 0.1;   % weight for the head distance error.
i_fr  = 1;

P = init_P;
third_P = P(:, 3);
all_errors = [];

[third_P, fval] = fminsearch(@min_fun, third_P, optimset('MaxIter', 100,  'MaxFunEvals', 500000, 'Display','off'));


% This is the neested function will try to minimize.
% It is the sum of the difference between angles of the extracted
% and the ones predicted by the projection matrix
    function x = min_fun(third_P)
        inside_P = P;
        inside_P(:, 3) = third_P;
        H = [P(:, 1:2) P(:, 4)];
        
        
        % compute the pole predicted by P
%         [feet_points; ones(1, size(feet_points,2))]
        w_feet_point = ics2wcs_H([feet_points; ones(1, size(feet_points,2))], H);
        w_head_point = [w_feet_point(1,:); w_feet_point(2,:); ones(1, size(feet_points,2)).*1650; ones(1, size(feet_points,2))];
        im_head_point = wcs2ics(w_head_point, inside_P);
        
        v1  = head_points  - feet_points ;
        v2  = im_head_point - feet_points;
        norm_v1 = arrayfun(@(idx) norm(v1(:,idx)), 1:size(v1,2));
        norm_v2 = arrayfun(@(idx) norm(v2(:,idx)), 1:size(v2,2));
        ang = real(acos(dot(v1,v2)./(norm_v1.*norm_v2) )) ;
        
        dist_head = im_head_point - head_points;
        d_error = arrayfun(@(idx) norm(dist_head(:,idx)), 1:size(dist_head,2));
        errors = alpha*ang + beta*d_error;
        
        errors = errors.*weights';
        
        i_fr = i_fr + 1;
        
        % remove outliers from the errors
        med_score = median(errors);
        first_quartile = median(errors(errors < med_score));
        third_quartile = median(errors(errors > med_score));
        iq = third_quartile - first_quartile;
        upper_inner_fence = third_quartile + 1.5*iq;
        in_errors = errors(errors <= upper_inner_fence);
        
        x = sum(in_errors);
%         fprintf('%f\n', x);
        
        all_errors = [all_errors x];
        
    end
% fprintf('%d iteraction\n', length(all_errors));
% plot(all_errors, 'b');

P(:, 3) = third_P;
final_error = all_errors(end);

% disp('The final matrix:');
% disp(P);

end























