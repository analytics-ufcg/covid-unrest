library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(stringr, quietly = TRUE)
library(lubridate, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)
library(stringi)

# Download file at http://tiny.cc/idb-traffic-weekly

load_congestion_data <- function(file) {
  read_csv(file, col_types = cols())
}

process_congestion_states <- function(raw){
  p = raw %>%
    filter(country_name == "Brazil") %>%
    select(week_number,
           region_type,
           region_name,
           ratio_congestion = ratio_20,
           percentage_congestion_change = tcp) %>%
    janitor::clean_names() 
  
  state_codes = read_csv(here::here("data/ready/state-codes-ibge.csv"),
                         col_types = cols(.default = col_character())) %>% 
    mutate(uf_name2 = stringi::stri_trans_general(uf_name, "Latin-ASCII") %>% str_to_lower())
  
  states = p %>% 
    mutate(region_name = str_to_lower(region_name)) %>% 
    filter(region_type == "state") %>% 
    left_join(state_codes, by = c("region_name" = "uf_name2"))

  states
}

process_congestion_cities <- function(raw){
  p = raw %>%
    filter(country_name == "Brazil") %>%
    select(week_number,
           region_type,
           region_name,
           ratio_congestion = ratio_20,
           percentage_congestion_change = tcp) %>%
    janitor::clean_names() 
  
  city_codes = read_csv(here::here("data/ready/city-codes-ibge.csv"), 
                        col_types = cols(.default = col_character())) %>% 
    mutate(municipio_name2 = stringi::stri_trans_general(municipio_name, "Latin-ASCII") %>% str_to_lower())
  
  cities = p %>%
    mutate(region_name = stringi::stri_trans_general(str_to_lower(region_name), "Latin-ASCII")) %>%
    filter(region_type == "city") %>%
    left_join(city_codes, by = c("region_name" = "municipio_name2"))
  
  cities
}


main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "waze_idb.csv")
  )
  
  
  data_raw <- load_congestion_data(input_file)
  data_ready_cities <- process_congestion_cities(data_raw)
  data_ready_states <- process_congestion_states(data_raw)
  
  write_csv(data_ready_cities, here::here("data", "ready", "congestion-cities.csv"), na = "")
  write_csv(data_ready_states, here::here("data", "ready", "congestion-states.csv"), na = "")
  message("Data written")
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
