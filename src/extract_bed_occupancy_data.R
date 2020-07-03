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
    rename(metrica = 1) %>%
    mutate(metrica = case_when(
      str_detect(metrica, fixed("C1a")) ~ "taxa_ocupacao_uti",
      str_detect(metrica, fixed("C1b")) ~ "taxa_ocupacao_enfermaria",
      str_detect(metrica, fixed("C2a")) ~ "crescimento_casos_semanal",
      str_detect(metrica, fixed("C2b")) ~ "crescimento_obitos_semanal",
      str_detect(metrica, fixed("C3a")) ~ "indice_isolamento_medio",
      TRUE ~ NA_character_)) %>%
    filter(!is.na(metrica)) %>%
    mutate_at(vars(-metrica), as.double) %>%
    pivot_longer(-metrica, names_to = "estado") %>% 
    pivot_wider(id_cols = "estado", names_from=metrica, values_from=value)
    
    return(res)
}

extract_transform_mandacaru_data <- function(mandacaru_xlsx) {
  sheet_names <- excel_sheets(mandacaru_xlsx)
  sheet_ids <- seq_along(sheet_names)
  names(sheet_ids) <- sheet_names
  
  res <- sheet_ids %>%
    map_df(extract_transform_sheet, mandacaru_xlsx, .id = "data") %>%
    mutate(data = parse_date(paste(data, "2020"), format = "%d %b %Y"))
  
  return(res)
}

write_bed_occupancy <- function(mandacaru_data, output_csv) {
  mandacaru_data %>%
    filter(data == max(data)) %>%
    select(data, estado, taxa_ocupacao_uti, taxa_ocupacao_enfermaria) %>%
    transmute(
      data,
      estado,
      taxa_ocupacao_uti = round(taxa_ocupacao_uti / 100, 3),
      taxa_ocupacao_enfermaria = round(taxa_ocupacao_enfermaria / 100, 3)) %>%
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
  