### update_data.R ###
# Lorae Stojanovic
# LE: 2/6/2024
# This script updates data from XXXX.xlsx using sources from BEA, FRED, and 
# OTHER.
#
# This script has 3 sections:
# 0: CONFIGURATION
# 1: LOAD DATA
# 2: POTENTIAL GDP

##### 0: CONFIGURATION #####
# Packages
  library("readxl") # read Excel sheets
  library("zoo") # handle year-quarter data
  library("magrittr") # use pipe operator %>%
  library("httr") # make API requests
  library("dplyr") # Manipulate data (filter, arrange, summarize, etc.)
  library("purrr") # Functional programming tools for working with lists

# Environment variable config
  setwd(WD_PATH) # WD_PATH is specified in .env and loaded in init.R

# Set current quarter. For now, I'll just make it a variable.
  # TODO: prompt user or functionalize this script
  current_quarter <- "2024 Q1" %>%
    as.yearqtr(., format = "%Y Q%q")

##### 1: LOAD DATA #####
## Load historical and forecast versions of FIM components, macro data, and MPCs
## TODO: Loop this
  # FIM components
  # historical data on FIM components
  h.itemized <- read_xlsx(path = "mock-data.xlsx", sheet = "h.itemized", skip = 2) %>% 
    mutate(yq = as.yearqtr(.$yq)) # convert "yq" column to yearqtr format
  # forecast FIM components
  f.itemized <- read_xlsx(path = "mock-data.xlsx", sheet = "f.itemized", skip = 2) %>%
    mutate(yq = as.yearqtr(.$yq)) # convert "yq" column to yearqtr format
  # historical macro data (like GDP)
  h.macro <- read_xlsx(path = "mock-data.xlsx", sheet = "h.macro", skip = 2) %>% 
    mutate(yq = as.yearqtr(.$yq)) # convert "yq" column to yearqtr format
  # forecast macro data (like GDP)
  f.macro <- read_xlsx(path = "mock-data.xlsx", sheet = "f.macro", skip = 2) %>% 
    mutate(yq = as.yearqtr(.$yq)) # convert "yq" column to yearqtr format
  # TODO: Add MPCs later
  # mpc <- read_xlsx(path = "mock-data.xlsx", sheet = "mpc")


##### 2: POTENTIAL GDP ##### 
# Make API request to FRED to get real potential GDP time series. For more information
# on the API request, visit https://fred.stlouisfed.org/docs/api/fred/series_observations.html
# For more information on the time series, visit https://fred.stlouisfed.org/series/GDPPOT
fred_url <- "https://api.stlouisfed.org/fred/series/observations"  # URL for API request
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
response <- GET(fred_url, query = params) %>% # Make GET request
  content(., "parsed") # Parse JSON response
# Convert the observations list in response to a data frame
new_potgdp <- map_dfr(response$observations, ~ data.frame(
  yq = as.Date(.x$date) %>%  # reformat "date" column to date
    as.yearqtr(), # then to yearqtr (for some reason doing this in one step doesn't work)
  potgdp = as.numeric(.x$value)  # reformat "value" column to numeric
))
# Quarter-over-quarter change in potential GDP is neutral counterfactual rate 
# of growth that we use in the FIM. Any growth in, e.g. taxes in excess of or 
# short of that growth rate registers into the FIM.
# gdppot <- gdppot %>%
#   mutate(neutral_chg = (value / lag(value)))  # calculate change in gdppot