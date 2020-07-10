library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(tidyr)
library(stringr, quietly = TRUE)
library(lubridate, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Download file at https://docs.google.com/spreadsheets/d/18z8H9sR13HDQ007kCKJRJ_Y9gNCacjHRPW9j28aRlUk/edit#gid=106766150

load_transp_data <- function(file) {
  read_csv(file, col_types = cols(), skip = 1) %>% 
    rename(uf = X1)
}

process_transp <- function(raw){
  raw %>%
    select(1:12) %>% 
    pivot_longer(2:12, names_to = "date", values_to = "index") %>% 
    mutate(date = lubridate::dmy(str_glue("{date}/2020"))) %>% 
    janitor::clean_names() 
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "ok-covid-transparency.csv")
  )
  
  output_file <- ifelse(length(argv) >= 2, argv[2],
                        here::here("data", "ready", "transparency.csv"))
  
  data_raw <- load_transp_data(input_file)
  data_ready <- process_transp(data_raw)
  
  write_csv(data_ready, output_file, na = "")
  message("Data written to ", output_file)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
