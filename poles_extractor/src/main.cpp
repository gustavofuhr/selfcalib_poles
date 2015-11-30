#include "poles_extractor.h"


int main(int argc, char *argv[]) 
{
	if (argc < 2)
	{
		std::cout << " # Argument Error: this program requires a conf file." << std::endl;
		return 1;
	}
	else
	{
		std::string cfg_filename(argv[1]);
		PolesExtractor poles_extractor(cfg_filename);
		
		poles_extractor.run();
		
		std::cout << "\nDone.\n";
		return 0;
	}
}
