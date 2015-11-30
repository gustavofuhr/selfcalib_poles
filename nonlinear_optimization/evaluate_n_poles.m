clear; close all; clc;

options = pets_config();

load(options.poles_file);
addpath('../evaluate_results/');

sample_perc = 0.1:0.1:1.0;

errors = [];
for i = 1:length(sample_perc)
    sample_perc(i)
    this_errors = zeros(50, 1);
    for t = 1:50
        if sample_perc(i) == 1.0
            h_pts_samp = h_pts;
            f_pts_samp = f_pts;
        else
            [h_pts_samp, f_pts_samp] = sample_poles_for_evaluation(h_pts, f_pts, sample_perc(i));
        end
    
        P = test_whole_calibration(h_pts_samp, f_pts_samp, options);
        options.P_estimate = P;
        error_P = evaluate_calibration(options.P_gt, options.P_estimate, options, true);
        this_errors(t) = error_P;
    end
    
   errors = [errors; this_errors']
end


figure;
errorbar(mean(errors, 2), std(errors, 2), '-r');
disp('Save the errors!');
