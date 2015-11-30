clear; close all; clc;

options = towncentre_config();

load(options.poles_file);
addpath('../evaluate_results/');

sample_perc = 0.1;

errors = [];
n_samples = 300;

var_error_samples = zeros(2, n_samples);

for t = 1:n_samples
    [h_pts_samp, f_pts_samp] = sample_poles_for_evaluation(h_pts, f_pts, sample_perc);

    [P, var] = test_whole_calibration(h_pts_samp, f_pts_samp, options);
    options.P_estimate = P;
    error_P = evaluate_calibration(options.P_gt, options.P_estimate, options, true);

    var_error_samples(:,t) = [var; error_P];
end


figure;
plot(var_error_samples(1,:), var_error_samples(2,:), 'or');
disp('Save the errors!');
