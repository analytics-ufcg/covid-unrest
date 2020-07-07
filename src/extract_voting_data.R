library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Download json from https://eleicoes.datapedia.info/api/votes/bycountry/244/2254251

load_votes_data <- function(file) {
  jsonlite::fromJSON(file, flatten = T)
}

process_votes <- function(raw){
  raw %>%
    filter(phase == 2) %>%
    mutate(proportion_bolsonaro = votable_votes / total_votes) %>% 
    select(state = location,
           state_code = location_code,
           proportion_bolsonaro) %>%
    janitor::clean_names() 
}

process_votes_cities <- function(raw){
  raw %>%
    filter(phase == 2) %>%
    mutate(proportion_bolsonaro = votable_votes / total_votes) %>% 
    select(city = location,
           city_code = location_code,
           proportion_bolsonaro) %>%
    janitor::clean_names() 
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "bolsonaro-votes-states.json")
  )
  
  input_file2 <- ifelse(
    length(argv) >= 1,
    argv[2],
    here::here("data", "raw", "bolsonaro-votes-cities.json")
  )
  
  output_file <- ifelse(length(argv) >= 1, argv[3],
                        here::here("data", "ready", "voting-states.csv"))
  
  output_file2 <- ifelse(length(argv) >= 1, argv[4],
                        here::here("data", "ready", "voting-cities.csv"))
  
  
  data_raw <- load_votes_data(input_file)
  data_ready <- process_votes(data_raw)
  write_csv(data_ready, output_file, na = "")
  message("Data written to ", output_file)
  
  data_raw2 <- load_votes_data(input_file2)
  data_ready2 <- process_votes_cities(data_raw2)
  write_csv(data_ready2, output_file2, na = "")
  message("Data written to ", output_file2)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
