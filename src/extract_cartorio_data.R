library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(here, quietly = TRUE)
library(purrr, quietly = TRUE)
library(readr, quietly = TRUE)
library(tidyr, quietly = TRUE)

# Download file at https://data.brasil.io/dataset/covid19/obito_cartorio.csv.gz

load_cartorio_data <- function(file) {
  cartorio <- read_csv(file, col_types = cols())
  return(cartorio)
}

aggregate_deaths_per_epiweek <- function(cartorio_data) {
  agg_vars_funs <- list(.vars = list(vars(date),
                                     vars(starts_with("new")),
                                     vars(starts_with("deaths"))),
                        .funs = list(min, sum, max))
  
  cartorio_week_2019 <- agg_vars_funs %>%
    pmap(~ cartorio_data %>%
           select(state, date, ends_with("2019")) %>%
           group_by(state, epidemiological_week = epidemiological_week_2019) %>%
           summarise_at(.x, .y)) %>%
    reduce(inner_join, by = c("state", "epidemiological_week")) %>%
    rename(first_day_epiweek_2019 = date)
  
  cartorio_week_2020 <- agg_vars_funs %>%
    pmap(~ cartorio_data %>%
           select(state, date, ends_with("2020")) %>%
           group_by(state, epidemiological_week = epidemiological_week_2020) %>%
           summarise_at(.x, .y)) %>%
    reduce(inner_join, by = c("state", "epidemiological_week")) %>%
    rename(first_day_epiweek_2020 = date)

  cartorio_week <- cartorio_week_2019 %>%
    full_join(cartorio_week_2020, by = c("state", "epidemiological_week")) %>%
    select(state, epidemiological_week, first_day_epiweek_2019,
           first_day_epiweek_2020, sort(names(.)))
  
  return(cartorio_week)
}

main <- function(argv = NULL) {
  input_file <- ifelse(length(argv) >= 1, argv[1],
                                here("data", "raw", "obito_cartorio.csv.gz"))
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
