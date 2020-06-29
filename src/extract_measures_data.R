library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(stringr, quietly = TRUE)
library(lubridate, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE)

# Download file at https://github.com/OxCGRT/Brazil-covid-policy/blob/master/data/OxCGRT_Brazil_Subnational_31May2020.csv

load_measures_data <- function(file) {
  read_csv(file, col_types = cols())
}

process_measures <- function(raw){
  raw %>% 
    mutate_at(vars(RegionCode, CityCode), str_remove, "BR_") %>% 
    mutate(Date = ymd(Date)) %>% 
    select(uf = RegionCode, 
           CityName, 
           CityCode, 
           Date, 
           StringencyIndex) %>% 
    janitor::clean_names() 
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "OxCGRT_Brazil_Subnational_31May2020.csv")
  )
  
  output_file <- ifelse(length(argv) >= 2, argv[2],
                        here::here("data", "ready", "measures-stringency-week.csv"))
  
  measures_raw <- load_measures_data(input_file)
  measures_ready <- process_measures(measures_raw)
  
  write_csv(measures_ready, output_file, na = "")
  message("Data written to ", output_file)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
