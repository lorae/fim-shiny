# fim-shiny
A revised version of the Hutchins Center Fiscal Impact Measure (FIM) that is portable and produces an interactive Shiny dashboard.

# Interpreting changes from previous runs
This project has a history folder, which contains every previous recorded run. The goal is to ensure that we can accurately explain every piece of the FIM and how it changed: what portion changed due to a change in the prediction, what portion changed due to a change in our MPC function, etc.
- change in forecast
- data revision
- change in MPC assumption
- addition of a new variable
- removal of an old variable
- change in deflator

We can capture all of these changes by comparing previous and new forecast and MPC sheets.

This is what I envision.  
1. A function, called calculate_fim, which takes forecast and mpc sheets (and deflator) as an input and output the fim. It will explain how every fim component contributes to the fim.

2. A function which compares two fims. It will take as input two calculate_fim results and output the following:
- it will identify the 6 types of changes above (e.g. change in forecast and data revisision etc) group them together by type. E.g. there could be multiple changes in forecast
- explain how each of those have changed the fim.

3. A google drive folder with every name and date of a run on it. These will title individual folders. Saved within each folder are:
- the forecast,mpc, and deflator sheets used in the run.
- a dashboard showing the fim contributions (or should that not be saved and instead separately calculted?)
  
