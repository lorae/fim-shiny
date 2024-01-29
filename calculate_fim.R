### calculate-fim.R ###
# Lorae Stojanovic
# LE: 1/29/2024
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
library("httr") # make API requests
library("dplyr") # Manipulate data (filter, arrange, summarize, etc.)
library("purrr") # Functional programming tools for working with lists

setwd(WD_PATH) # WD_PATH is specified in .env and loaded in init.R

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
# Make API request to FRED to get potential GDP time series. For more information,
# visit https://fred.stlouisfed.org/docs/api/fred/series_observations.html
  url <- "https://api.stlouisfed.org/fred/series/observations"  # Define URL
  params <- list(  # Define parameters
    api_key = FRED_API_KEY,  # API key is specified in .env and loaded in init.R
    file_type = "json",  # Data returned in JSON format
    series_id = "GDPPOT",  # Potential GDP
    observation_start = "2017-01-01",
    observation_end = "2023-12-31",
    units = "lin",  # Data returned as levels (no transformation)
    frequency = "q",  # Data returned quarterly
    aggregation_method = "eop"  # Data returned from end of period
    # TODO: may want to add real-time period https://fred.stlouisfed.org/docs/api/fred/realtime_period.html
    ) 
  response <- GET(url, query = params) %>% # Make GET request
    content(., "parsed") # Parse JSON response
  # Convert the observations list in response to a data frame
  gdppot <- map_dfr(response$observations, ~ data.frame(
    Date = as.Date(.x$date),
    Value = as.numeric(.x$value)
  ))




