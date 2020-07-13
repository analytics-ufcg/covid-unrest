library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(here, quietly = TRUE)
library(readr, quietly = TRUE)
library(readxl, quietly = TRUE)

# Download xslx file at ftp://geoftp.ibge.gov.br/organizacao_do_territorio/estrutura_territorial/divisao_territorial/2018/DTB_2018.zip

load_city_data <- function(file_xlsx) {
  city_data <- read_xls("data/raw/RELATORIO_DTB_BRASIL_MUNICIPIO.xls") %>%
    janitor::clean_names() %>%
    select(uf_code = uf, 
           uf_name = nome_uf, 
           municipio_code_short = municipio, 
           municipio_code = codigo_municipio_completo, 
           municipio_name = nome_municipio)
  
  return(city_data)
}

process_city_codes = function(city_data){
  uf_extra = jsonlite::fromJSON("https://servicodados.ibge.gov.br/api/v1/localidades/estados", 
                                flatten = T) %>% 
    janitor::clean_names() %>% 
    mutate_at(vars(everything()), as.character)
  
  city_data %>% 
    left_join(uf_extra, 
              by = c("uf_code" = "id", 
                     "uf_name" = "nome")) %>% 
    rename(uf_sigla = sigla, 
           regiao_code = regiao_id, 
           regiao_name = regiao_nome)
}

main <- function(argv) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "RELATORIO_DTB_BRASIL_MUNICIPIO.xls")
  )
  
  output_file <- ifelse(
    length(argv) >= 2, tolower(argv[2]),
    here("data", "ready", paste0("city-codes-ibge.csv"))
  )

  raw_data <- load_city_data(input_file)
  city_data <- process_city_codes(raw_data)
  write_csv(city_data, output_file, na = "")
  message("Data written to ", output_file)
  
  states_data = city_data %>% 
    select(-municipio_code, -municipio_code_short, -municipio_name) %>% 
    distinct()
  
  write_csv(states_data, here("data", "ready", "state-codes-ibge.csv"), na = "")
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
