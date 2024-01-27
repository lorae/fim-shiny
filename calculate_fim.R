### calculate-fim.R ###
# Lorae Stojanovic
# LE: 1/27/2024
# The workhorse script of the fim-shiny repo, which calculates the FIM given a 
# set of input MPCs and forecasts.
#
# This script has 3 sections:
# 0: CONFIGURATION
# 1: LOAD DATA
# 2: MINUS NEUTRAL

##### 0: CONFIGURATION #####
library("readxl") # read Excel sheets
library("zoo") # handle year-quarter data
library("magrittr") # use pipe operator %>%

setwd("YOUR WD HERE")

##### 1: LOAD DATA #####
## Load historical data, predictions, and MPCs
# TODO: I may want to combine these three sheets into one workbook later
historical <- read_xlsx(path = "mock-historical.xlsx", sheet = "data")
forecast <- read_xlsx(path = "mock-forecast.xlsx", sheet = "data")
mpc <- read_xlsx(path = "mock-forecast.xlsx", sheet = "mpc")

# current quarter is the last column name of historical
current_quarter <- tail(names(historical), 1) %>%
  as.yearqtr(., format = "%Y Q%q")

##### 2: MINUS NEUTRAL #####


