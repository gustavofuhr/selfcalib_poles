#include "poles_extractor.h"
#include <highgui.h>
#include <vector>

#include <plot_utils.h>

#include "interface_utils.h"

PolesExtractor::PolesExtractor(std::string &config_filename):
	config(config_filename),
	person_detector(config_filename)
{
}



std::vector<bool> PolesExtractor::manual_validation(PolesArray &poles, cv::Mat &frame) {
    std::string window_name = "Poles extracted, click to validate. ESC for next frame";
    cv::imshow(window_name, frame);
    MouseHandler mh(window_name);

    int n_poles = poles.size();
    int radius_click = 10;
    // first plot a region to around the point to be clicked if one
    // wants to save this plot
    for (int i = 0; i < n_poles; ++i) {
        cv::circle(frame, poles[i].feet_point, radius_click, cv::Scalar(0, 0, 0), 1);
    }
    cv::imshow(window_name, frame);

    std::vector<bool> valid_poles(n_poles, false);

    while (true) {
        cv::Point2i pt(-1,-1);
        mh.wait_click(pt);

        // if point = [0, 0] no click was done, so it is over
        if (pt.x == -1 && pt.y == -1) break;

        // se if some point was clicked
        cv::Point2f fpt;
        fpt.x = (float)pt.x;
        fpt.y = (float)pt.y;

        for (int i = 0; i < n_poles; ++i) {
            float dist = cv::norm(fpt - poles[i].feet_point);
            if (dist < radius_click) {
                poles[i].plot(frame, cv::Scalar(0,0,255));

                valid_poles[i] = true;
            }
        }

        cv::imshow(window_name, frame);

    }

    return valid_poles;
}

void PolesExtractor::run() {
	config.stream->open();

    // use the video recorder if necessary
    VideoRecorder* vid_recorder;
    if (config.save_result_video) {
        vid_recorder = new VideoRecorder(config.output_path + config.result_video_name);
    }

    PolesArray all_poles;
    while (!config.stream->has_ended()) {
    	cv::Mat frame = config.stream->get_next_frame();
        int frame_number = config.stream->get_current_frame_number();
        std::cout << "Fr:" << frame_number  << " " << std::flush;
        
        PolesArray curr_poles = get_poles(frame, frame_number);

        // plot all the frames
        for (int i=0; i < curr_poles.size(); ++i) {
        	curr_poles[i].plot(frame);
        }

        if (config.save_result_video) {
            vid_recorder->save_frame(frame);
        }

        
        if (config.manual_validation && curr_poles.size() > 0) {
            std::vector<bool> this_frame_validations;
            this_frame_validations = manual_validation(curr_poles, frame);
            for (int i = 0; i < this_frame_validations.size(); ++i) {
                if (this_frame_validations[i]) {
                    all_poles.push_back(curr_poles[i]);
                }
            }
        }
        else {
            cv::imshow("Poles extracted", frame);
            if ((char)cv::waitKey(10) == 27) break;
        }
    }

    if (config.save_matlab_file) {
        // save in a txt file to import in matlab
        int n_poles = all_poles.size();
        cv::Mat_<double> h_pts(2, n_poles);
        cv::Mat_<double> f_pts(2, n_poles);

        for (int i = 0; i < n_poles; ++i) {
            h_pts(0, i) = all_poles[i].head_point.x;
            h_pts(1, i) = all_poles[i].head_point.y;

            f_pts(0, i) = all_poles[i].feet_point.x;
            f_pts(1, i) = all_poles[i].feet_point.y;
        }

        std::ofstream out_file;
        std::cout << std::endl << "Saving file: " << config.output_path + config.out_eval_matlab_file << std::endl;
        out_file.open(config.output_path + config.out_eval_matlab_file);
        out_file << "h_pts = " << h_pts << ";" << std::endl;
        out_file << "f_pts = " << f_pts << ";" << std::endl; 
        out_file.close();
    }
}


PolesArray PolesExtractor::get_poles(cv::Mat &image, int frame) {

	// first make the detection of the image
	cv::Mat *fg_mask = new cv::Mat(image.rows, image.cols, CV_8UC3);
    BB_Array detections = person_detector.detect(image, NULL, -1, fg_mask);
    PolesArray result_poles;
    
    for (int i = 0; i < detections.size(); ++i) {
        // get the foreground inside the detection
        cv::Mat detection_foreground(*fg_mask, detections[i].toRect());

        Pole p = foreground2pole(detection_foreground);
        p.frame = frame;
        
        p.head_point.x = p.head_point.x + detections[i].topLeftPoint.x;
        p.head_point.y = p.head_point.y + detections[i].topLeftPoint.y;
        
        p.feet_point.x = p.feet_point.x + detections[i].topLeftPoint.x;
        p.feet_point.y = p.feet_point.y + detections[i].topLeftPoint.y;
        

        result_poles.push_back(p);

    }

    return result_poles;
	

}

Pole PolesExtractor::foreground2pole(cv::Mat &fg_mask) {
    cv::PCA pca;

    // create the points x,y using the foreground pixels
    std::vector< std::vector<double> > foreground_pixels;
    for (int i = 0; i < fg_mask.rows; ++i) {
        for (int j = 0; j < fg_mask.cols; ++j) {
            if (fg_mask.at<uchar>(i,j) > 0) {
                std::vector<double> pixel(2, 0);
                pixel[0] = i;
                pixel[1] = j;
                foreground_pixels.push_back(pixel);
            }
        }
    }
    
    cv::Mat pca_points(foreground_pixels.size(), foreground_pixels.at(0).size(), CV_64FC1);
    for(int i=0; i< pca_points.rows; ++i) {
        for(int j=0; j< pca_points.cols; ++j) {
            pca_points.at<double>(i, j) = foreground_pixels.at(i).at(j);
        }
    }

    pca(pca_points, cv::noArray(), CV_PCA_DATA_AS_ROW);
    
    cv::Point3f center;
    center.x = fg_mask.cols/2.0;
    center.y = fg_mask.rows/2.0;
    center.z = 1.0;

    cv::Point3f next_point;
    next_point.x = center.x + pca.eigenvectors.at<double>(0, 1)*sqrt(pca.eigenvalues.at<double>(0));
    next_point.y = center.y + pca.eigenvectors.at<double>(1, 1)*sqrt(pca.eigenvalues.at<double>(0));
    next_point.z = 1.0;

    cv::Point3f line;
    line = center.cross(next_point);

    cv::Point2f head_point(-1, -1);
    cv::Point2f feet_point(-1, -1);
    for (int y = 0; y < fg_mask.rows; ++y) {
        // using the line see the point in x
        double fx = ( -line.y*y -line.z) / line.x;
        int x = (int)fx;

        // this loop is running from the head to toes, so if the head was not
        // defined, set the value (the first non zero)
        if (head_point.x == -1 && head_point.y == -1 && fg_mask.at<uchar>(y,x) > 0) {
            head_point.x = x; head_point.y = y;
        }
        if (fg_mask.at<uchar>(y,x) > 0) {
            feet_point.x = x; feet_point.y = y;
        }
    }

    Pole resulting_pole;
    resulting_pole.head_point = head_point;
    resulting_pole.feet_point = feet_point;

    return resulting_pole;
}

