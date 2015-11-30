#pragma once

#include <vector>
#include <cv.h>



class Pole {
public:
	cv::Point2f feet_point, head_point;
	int frame;
	void plot(cv::Mat &image, cv::Scalar pole_color = cv::Scalar(255,0,0));
};

typedef std::vector<Pole> PolesArray;