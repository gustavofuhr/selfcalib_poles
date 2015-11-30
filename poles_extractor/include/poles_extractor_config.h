#pragma once

#include <fstream>
#include <video_stream.h>

class PolesExtractorConfig{

public:
	video_stream *stream;
	bool save_matlab_file, save_result_video, manual_validation;
	std::string out_eval_matlab_file;
	std::string result_video_name;
	std::string output_path;

	PolesExtractorConfig(std::string &config_filename);

};