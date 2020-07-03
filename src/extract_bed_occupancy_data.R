library(dplyr)
library(here)
library(lubridate)
library(purrr)
library(readxl)
library(readr)
library(stringr)
library(tidyr)

Sys.setlocale(locale = "pt_BR")

extract_transform_sheet <- function(sheet_id, mandacaru_xlsx) {
  res <- read_excel(mandacaru_xlsx, sheet = sheet_id) %>%
    rename(metric = 1) %>%
    mutate(metric = case_when(
      str_detect(metric, fixed("C1a")) ~ "icu_beds_occupancy",
      str_detect(metric, fixed("C1b")) ~ "hospital_beds_occupancy",
      str_detect(metric, fixed("C2a")) ~ "cases_increase_week",
      str_detect(metric, fixed("C2b")) ~ "deaths_increase_week",
      str_detect(metric, fixed("C3a")) ~ "social_isolation_index",
      TRUE ~ NA_character_)) %>%
    filter(!is.na(metric)) %>%
    mutate_at(vars(-metric), as.double) %>%
    pivot_longer(-metric, names_to = "state") %>% 
    pivot_wider(id_cols = state, names_from = metric, values_from = value)
    
    return(res)
}

extract_transform_mandacaru_data <- function(mandacaru_xlsx) {
  sheet_names <- excel_sheets(mandacaru_xlsx)
  sheet_ids <- seq_along(sheet_names)
  names(sheet_ids) <- sheet_names
  
  res <- sheet_ids %>%
    map_df(extract_transform_sheet, mandacaru_xlsx, .id = "date") %>%
    mutate(date = parse_date(paste(date, "2020"), format = "%d %b %Y"))
  
  return(res)
}

write_bed_occupancy <- function(mandacaru_data, output_csv) {
  mandacaru_data %>%
    filter(date == max(date)) %>%
    select(date, state, icu_beds_occupancy, hospital_beds_occupancy) %>%
    transmute(
      date,
      state,
      icu_beds_occupancy = round(icu_beds_occupancy / 100, 3),
      hospital_beds_occupancy = round(hospital_beds_occupancy / 100, 3)) %>%
    write_csv(output_csv)
}

main <- function(argv) {
  mandacaru_xlsx <- ifelse(length(argv) >= 1, tolower(argv[1]), 
                           here("data", "raw", "planilha_covid_mandacaru.xlsx"))
  output_csv <- ifelse(length(argv) >= 2, argv[2],
                        here("data", "ready", "covid-bed-occupancy.csv"))
  
  mandacaru_data <- extract_transform_mandacaru_data(mandacaru_xlsx)
  write_bed_occupancy(mandacaru_data, output_csv)
}


if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
  