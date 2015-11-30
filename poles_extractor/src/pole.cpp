#include "pole.h"


void Pole::plot(cv::Mat &image, cv::Scalar pole_color) {
	// first plot the line it self
	cv::line(image, feet_point, head_point, pole_color, 2);

	// now the head and feet points
	cv::circle(image, feet_point, 4, cv::Scalar(0, 0, 255), -1);
	cv::circle(image, head_point, 4, cv::Scalar(0, 0, 255), -1);
}