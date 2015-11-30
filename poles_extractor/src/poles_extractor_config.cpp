#include "poles_extractor_config.h"


PolesExtractorConfig::PolesExtractorConfig(std::string &config_filename):
	save_matlab_file(false),
	stream(NULL)
{
	stream = read_video_stream(config_filename);

	std::ifstream in_file;
	in_file.open(config_filename);

	std::string token;
	while (in_file >> token) {
		if (token == "save_matlab_file" && in_file >> token && token == "=") {
			std::string sbool;
			in_file >> sbool;
			save_matlab_file = (sbool == "true");
		}
		else if (token == "out_eval_matlab_file" && in_file >> token && token == "=") {
			in_file >> out_eval_matlab_file;
		}
		else if (token == "result_video_name" && in_file >> token && token == "=") {
			in_file >> result_video_name;
		}
		else if (token == "output_path" && in_file >> token && token == "=") {
			in_file >> output_path;
		}
		else if (token == "save_result_video" && in_file >> token && token == "=") {
			std::string sbool;
			in_file >> sbool;
			save_result_video = (sbool == "true");
		}
		else if (token == "manual_validation" && in_file >> token && token == "=") {
			std::string sbool;
			in_file >> sbool;
			manual_validation = (sbool == "true");
		}
			

	}
	

}