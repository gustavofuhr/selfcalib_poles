#pragma once

#include <cv.h>
#include <highgui.h>

class MouseHandler {
	public:
		bool wait_click(cv::Point2i &ret_clicked_point);

		/*constructors*/
		MouseHandler(const std::string &window_name);

    private:
		bool clicked;
		cv::Point2i clicked_point;
		static void on_mouse( int event, int x, int y, int flags, void* param );
};