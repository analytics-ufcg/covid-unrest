library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(here, quietly = TRUE)
library(lubridate, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(tidyr, quietly = TRUE)

# Download file at https://brasil.io/dataset/covid19/obito_cartorio/?format=csv

load_cartorio_data <- function(file) {
  cartorio <- read_csv(file, col_types = cols(), guess_max = 10^4)
  return(cartorio)
}

aggregate_deaths_per_epiweek <- function(cartorio_data, group_causes = TRUE,
                                         wider_output = TRUE) {
  cartorio_longer <- cartorio_data %>%
    select(date, epidemiological_week_2020, state,
           deaths_covid19_2020 = deaths_covid19, starts_with("deaths_")) %>%
    pivot_longer(starts_with("deaths_"), names_to = c("cause", "year"),
                 names_pattern = "deaths_(.*)_(.*)",
                 names_transform = list(year = as.integer),
                 values_to = "deaths") %>%
    group_by(state, year, cause) %>%
    arrange(date) %>%
    tidyr::fill(deaths) %>% # fill NAs with previous non-NA value
    replace_na(replace = list(deaths = 0)) # initial NAs as zero
  
  if (group_causes) {
    cartorio_longer <- cartorio_longer %>%
      ungroup() %>%
      mutate(cause = case_when(
        cause == "total" ~ "total",
        cause == "covid19" ~ "covid19",
        cause %in% c("sars", "pneumonia", "respiratory_failure",
                     "indeterminate") ~ "other_respiratory",
        cause %in% c("septicemia", "others") ~ "others",
        TRUE ~ NA_character_)) %>%
      group_by(state, year, date, epidemiological_week_2020, cause) %>%
      summarise(deaths = if_else(all(is.na(deaths)), NA_real_,
                                 sum(deaths, na.rm = TRUE)))
  }
  
  cartorio_week <- cartorio_longer %>%
    group_by(state, year, cause, epidemiological_week_2020) %>%
    summarise(first_day_epiweek_2020 = min(date),
              deaths = max(deaths)) %>%
    arrange(.by_group = TRUE) %>%
    mutate(new_deaths = deaths - pmax(0, lag(deaths), na.rm = TRUE))

  if (wider_output) {
    cartorio_week <- cartorio_week %>%
      pivot_wider(names_from = c(cause, year),
                  names_glue = "{.value}_{cause}_{year}",
                  values_from = c(deaths, new_deaths)) %>%
      mutate(
        deaths_total_dif = deaths_total_2020 - deaths_total_2019,
        new_deaths_total_dif = new_deaths_total_2020 - new_deaths_total_2019) %>%
      select(state, epidemiological_week_2020, first_day_epiweek_2020,
             sort(tidyselect::peek_vars()))
  }
  
  return(cartorio_week)
}

main <- function(argv = NULL) {
  input_file <- ifelse(length(argv) >= 1, argv[1],
                                here("data", "raw", "obito_cartorio.csv"))
  output_file <- ifelse(length(argv) >= 2, argv[2],
                        here("data", "ready", "cartorio-deaths-week.csv"))
  
  cartorio_data <- load_cartorio_data(input_file)
  cartorio_data_week <- aggregate_deaths_per_epiweek(cartorio_data)
  
  write_csv(cartorio_data_week, output_file, na = "")
  message("Data written to ", output_file)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
