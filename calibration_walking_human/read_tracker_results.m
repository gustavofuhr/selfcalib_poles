function [tracker_results] = read_tracker_results(filename)


[frames, ids, tl_x, tl_y, br_x, br_y] = textread(filename, '%d %d %f %f %f %f');

res = [];
mfr = max(frames);
for i = 1:mfr
    res(i).bboxes = [];
    res(i).ids = [];
end

for i = 1:size(frames)
    i_frame = frames(i);

    res(i_frame).bboxes = [res(i_frame).bboxes; tl_x(i), tl_y(i), br_x(i), br_y(i)];
    res(i_frame).ids    = [res(i_frame).ids ids(i)];
end
tracker_results = res;
