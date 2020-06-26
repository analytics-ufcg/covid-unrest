library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(here, quietly = TRUE)
library(readxl, quietly = TRUE)

load_covid_data_ms <- function(xlsx_file, level = NULL) {
  res <- read_xlsx(xlsx_file, guess = 10^4) %>%
    mutate(
      populacaoTCU2019 = suppressWarnings(as.integer(populacaoTCU2019)),
      incidencia100k = round(10^5 * casosAcumulado / populacaoTCU2019, 2),
      mortalidade100k = round(10^5 * obitosAcumulado / populacaoTCU2019, 2)
    ) %>%
    arrange(estado, municipio, data)
  
  if (!is.null(level)) {
    res <- switch(level,
                  country = extract_covid_data_by_country(res),
                  state = extract_covid_data_by_state(res),
                  city = extract_covid_data_by_city(res),
                  res)
  }
  
  return(res)
}

extract_covid_data_by_country <- function(covid_data) {
  by_country <- covid_data %>%
    filter(!is.na(regiao), is.na(codmun), is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_country)
}

extract_covid_data_by_state <- function(covid_data) {
  by_state <- covid_data %>%
    filter(is.na(codmun), !is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_state)
}

extract_covid_data_by_city <- function(covid_data) {
  by_city <- covid_data %>%
    filter(!is.na(codmun), !is.na(estado)) %>%
    select_if(~any(!is.na(.)))
  
  return(by_city)
}

main <- function(argv) {
  if (length(argv) < 1) {
    stop(paste("Usage: Rscript extract_covid_data.R <covid-data-file.xlsx>",
               "[aggregation level (city, state, country)] [output csv file]"))
  }
  xlsx_file <- argv[1]
  agg_level <- ifelse(length(argv) >= 2, tolower(argv[2]), "state")
  output_file <- ifelse(
    length(argv) >= 3, tolower(argv[3]),
    here("data", "ready", paste0("covid-data-br-", agg_level, ".csv"))
  )

  covid_data <- load_covid_data_ms(xlsx_file, agg_level)
  write.csv(covid_data, output_file, row.names = FALSE, quote = FALSE)
  print(paste("Data written to", output_file))
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
