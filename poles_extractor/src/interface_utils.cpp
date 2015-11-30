#include "interface_utils.h"


void MouseHandler::on_mouse( int event, int x, int y, int flags, void* param ){

	if (event == CV_EVENT_LBUTTONDOWN) {
		MouseHandler *mh;
		mh = static_cast<MouseHandler*>(param);

		mh->clicked = true;
		mh->clicked_point.x = x;
		mh->clicked_point.y = y;
	}
}

MouseHandler::MouseHandler(const std::string &window_name) : clicked(false) {

	if (cvGetWindowHandle(window_name.c_str()) == NULL) {
		std::cerr << "First you need to create the window." << std::endl;
		exit(1);
	}

	cv::setMouseCallback(window_name.c_str(), on_mouse, this);
}

bool MouseHandler::wait_click(cv::Point2i &ret_clicked_point) {
	clicked = false;
	int key = 0;

	while (!clicked) {
		key = cv::waitKey(20);      
		if ((char)key == 27) break;
	}

	if (clicked)
		ret_clicked_point = clicked_point;

	return clicked;
}