This document explains the workflow structure of the project. As the project improves and the directory structure solidifies, it will likely be absorbed by README.md

## Project workflow

### Data
Test data will be saved for now in the main repository. The project will be designed in a modular way, such that new data can be "plugged in" to the main function and data won't necessarily be stored on GitHub.

### Workflow
Right now, 
- init.R runs initialization (read in secret API keys)
- calculate-fim.R runs brunt of calculations.


However, there's several improvements I'd like to make to calculate-fim.R. For now, it's using the FRED API to read in potential GDP. I'd preferably like the calculate-fim script to *only* run calculations, not to read in data. There can be a different script called update-data.R that does that stuff, including potential GDP. So I'd like to move the "calculate neutral" section to a new update-data.R script.

In calculate-fim, I want the only input to be an excel sheet (or something) containing all types of data: potential GDP; forecasts and historical data fo transfers, taxes and purchases; mpcs. a different script can handle updating all of that data.

