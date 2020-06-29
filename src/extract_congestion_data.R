library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(stringr, quietly = TRUE)
library(lubridate, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Download file at http://tiny.cc/idb-traffic-weekly

load_congestion_data <- function(file) {
  read_csv(file, col_types = cols())
}

process_congestion <- function(raw){
  raw %>%
    filter(country_name == "Brazil") %>%
    select(week_number,
           region_type,
           region_name,
           ratio_congestion = ratio_20,
           percentage_congestion_change = tcp) %>%
    janitor::clean_names() 
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "waze_idb.csv")
  )
  
  output_file <- ifelse(length(argv) >= 2, argv[2],
                        here::here("data", "ready", "congestion.csv"))
  
  data_raw <- load_congestion_data(input_file)
  data_ready <- process_congestion(data_raw)
  
  write_csv(data_ready, output_file, na = "")
  message("Data written to ", output_file)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
