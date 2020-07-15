library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(here, quietly = TRUE)
library(readr, quietly = TRUE)
library(readxl, quietly = TRUE)
library(tidylog, warn.conflicts = FALSE)

# Download xslx file at https://covid.saude.gov.br/

load_covid_data_ms <- function(file_xlsx, level = NULL) {
  city_codes_ibge <- read_csv(here("data", "ready", "city-codes-ibge.csv"),
                              col_types = cols()) %>%
    select(municipio_code, municipio_code6)
  
  covid_data <- read_xlsx(file_xlsx, guess = 10^4) %>%
    mutate(
      data = as.Date(data),
      populacaoTCU2019 = suppressWarnings(as.integer(populacaoTCU2019)),
      incidencia100k = round(10^5 * casosAcumulado / populacaoTCU2019, 2),
      mortalidade100k = round(10^5 * obitosAcumulado / populacaoTCU2019, 2)
    ) %>%
    arrange(estado, municipio, data) %>%
    left_join(city_codes_ibge, by = c("codmun" = "municipio_code6")) %>%
    relocate(municipio_code, .before = codmun) %>%
    select(-codmun) %>%
    janitor::clean_names() %>%
    rename(recuperados_novos = recuperadosnovos,
           cod_uf = coduf,
           cod_municipio = municipio_code)
  
  if (!is.null(level)) {
    covid_data <- switch(level,
                         country = extract_covid_data_by_country(covid_data),
                         state = extract_covid_data_by_state(covid_data),
                         city = extract_covid_data_by_city(covid_data),
                         covid_data)
  }
  
  return(covid_data)
}

extract_covid_data_by_country <- function(covid_data) {
  by_country <- covid_data %>%
    filter(!is.na(regiao), is.na(cod_municipio), is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_country)
}

extract_covid_data_by_state <- function(covid_data) {
  by_state <- covid_data %>%
    filter(is.na(cod_municipio), !is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_state)
}

extract_covid_data_by_city <- function(covid_data) {
  by_city <- covid_data %>%
    filter(!is.na(cod_municipio), !is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_city)
}

main <- function(argv) {
  if (length(argv) < 1) {
    stop(paste("Usage: Rscript extract_covid_data.R <covid-data-file.xlsx>",
               "[aggregation level (all, city, state, country)] [output dir]"))
  }
  xlsx_file <- argv[1]
  agg_level <- ifelse(length(argv) >= 2, tolower(argv[2]), "all")
  output_dir <- ifelse(length(argv) >= 3, argv[3], here("data", "ready"))
  
  all_agg_levels <- c("city", "state", "country")
  
  if (agg_level == "all") {
    agg_level <- all_agg_levels
  }
  
  for (agg in agg_level) {
    output_file <- file.path(output_dir, paste0("covid-data-br-", agg, ".csv"))
    covid_data <- load_covid_data_ms(xlsx_file, agg)
    write_csv(covid_data, output_file, na = "")
    message("Data written to ", output_file)
  }
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
