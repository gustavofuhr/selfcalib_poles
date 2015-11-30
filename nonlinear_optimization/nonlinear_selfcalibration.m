function [P, final_error] = nonlinear_selfcalibration(init_P, head_points, feet_points, options, weights)

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
        
%         imshow(options.im_frame); hold on;
        errors = zeros(length(head_points), 1);
        
        % compute the translation to keep the grid in the same place
        im_origin_point = [420; 115; 1];
        ts = ics2wcs_H(im_origin_point, H);
        
        tracking_area = [0, 20000; 0, 20000];
%         plot_axis(2000, H, inside_P, ts);
%         plot_grid(tracking_area, H, 500, ts);
        
        % TODO: this for can be otimized.
        for i = 1:length(head_points)
            
%             plot([head_points(1,i) feet_points(1,i)], [head_points(2,i) feet_points(2,i)], '-', 'Color', [24, 44, 180]./255, 'LineWidth', 1.5);
%             
%             plot([head_points(1,i)], [head_points(2,i)], 'o',  'MarkerSize', 4, 'Color', 'k', 'MarkerFaceColor', 'r');
%             plot([feet_points(1,i)], [feet_points(2,i)], 'o',  'MarkerSize', 4, 'Color', 'k', 'MarkerFaceColor', 'r');
            
            
            
            
            
            
            %old and ugly plot([feet_points(1,i), head_points(1,i)], [feet_points(2,i), head_points(2,i)], '-b');
            
            % compute the pole predicted by P
            w_feet_point = ics2wcs_H([feet_points(:,i); 1.0], H);
            w_head_point = [w_feet_point(1); w_feet_point(2); 1650; 1.0];
            im_head_point = wcs2ics(w_head_point, inside_P);
            
            
%             plot([im_head_point(1) feet_points(1,i)], [im_head_point(2) feet_points(2,i)], '-', 'Color', [180, 24, 44]./255, 'LineWidth', 1.5);
%             
%             plot([im_head_point(1)], [im_head_point(2)], 'o',  'MarkerSize', 4, 'Color', 'k', 'MarkerFaceColor', 'r');
%             plot([head_points(1,i)], [head_points(2,i)], 'o',  'MarkerSize', 4, 'Color', 'k', 'MarkerFaceColor', 'r');
            
            
            
            
            
            
            % old and ugly plot([feet_points(1,i), im_head_point(1)], [feet_points(2,i), im_head_point(2)], '-r');
            
            v1  = head_points(:,i) - feet_points(:,i);
            v2  = im_head_point - feet_points(:,i);
            ang = real(acos(dot(v1,v2)/ (norm(v1)*norm(v2)) ));
            
            errors(i) = alpha*ang + beta*norm(im_head_point - head_points(:,i));
            % DEBUG just for debug im using the distance of head points
            % sum_error = sum_error + norm(im_head_point - head_points(1,i));
        end
        
        errors = errors.*weights';
        
%         export_fig([options.out_path, '/frame_', format_int(4, i_fr), '.png'], '-a2');
%         hold off;
        i_fr = i_fr + 1;
        
        pause(0.05);
        
        % remove outliers from the errors
        med_score = median(errors);
        first_quartile = median(errors(errors < med_score));
        third_quartile = median(errors(errors > med_score));
        iq = third_quartile - first_quartile;
        upper_inner_fence = third_quartile + 1.5*iq;
        in_errors = errors(errors <= upper_inner_fence);
        
        x = sum(in_errors);
        fprintf('%f\n', x);
        
        all_errors = [all_errors x];
        
    end
% fprintf('%d iteraction\n', length(all_errors));
% plot(all_errors, 'b');

P(:, 3) = third_P;
final_error = all_errors(end);

% disp('The final matrix:');
% disp(P);

end























