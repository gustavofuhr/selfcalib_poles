#pragma once
#include <PersonDetector.h>

#include "poles_extractor_config.h"
#include "pole.h"


class PolesExtractor {
public:
	PolesExtractor(std::string &config_filename);
	void run();
	PolesArray get_poles(cv::Mat &image, int frame);
	Pole foreground2pole(cv::Mat &fg_mask);

private:
	PersonDetector person_detector;
	PolesExtractorConfig config;
	std::vector<bool> manual_validation(PolesArray &poles, cv::Mat &frame);

};