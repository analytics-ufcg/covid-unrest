library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Data was obtained from a data dump from Receita Federal

load_ngo_data <- function(file) {
  read_csv(file, col_types = cols())
}

process_ngo_states <- function(raw){
  state_codes = read_csv(here::here("data/ready/state-codes-ibge.csv"),
                         col_types = cols(.default = col_character())) 
  
  raw %>%
    count(uf, name = "ngo_count") %>% 
    filter(uf != "EX") %>% 
    left_join(state_codes, by = c("uf" = "uf_sigla")) %>% 
    janitor::clean_names() 
}

process_ngo_cities <- function(raw){
  chave_municipio = function(nome, uf){
    nome_l = stringi::stri_trans_general(nome, "Latin-ASCII") 
    str_to_lower(str_glue("{nome_l}-{uf}"))
  }
  
  city_codes = read_csv(here::here("data/ready/city-codes-ibge.csv"), 
                        col_types = cols(.default = col_character())) %>% 
    mutate(chave = chave_municipio(municipio_name, uf_sigla))

  large_cities = read_csv(here::here("data/ready/municipios_population.csv"),
                          col_types = "cccd") %>% 
    janitor::clean_names() %>% 
    filter(populacao_tcu2019 >= 250e3) %>% 
    mutate(chave = chave_municipio(municipio, estado))
  
  counts_all = raw %>%
    filter(uf != "EX") %>% 
    count(municipio, uf, name = "ngo_count") %>% 
    mutate(chave = chave_municipio(municipio, uf)) %>%
    right_join(large_cities, by = c("chave")) %>% 
    left_join(city_codes, by = c("chave", "uf" = "uf_sigla")) %>% 
    select(-municipio.x, -municipio.y, -estado, -chave, -codmun, ) %>% 
    mutate(ngo_1k_hab = ngo_count / populacao_tcu2019 * 1e3)
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data", "raw", "empresas-classe-94308.csv.zip")
  )
  
  output_file_cities <-
    here::here("data", "ready", "ongs-cities.csv")
  output_file_states <-
    here::here("data", "ready", "ongs-states.csv")
    
  data_raw <- load_ngo_data(input_file)
  data_states <- process_ngo_states(data_raw)
  data_cities <- process_ngo_cities(data_raw)
  
  write_csv(data_states, output_file_states, na = "")
  message("Data written to ", output_file_states)
  
  write_csv(data_cities, output_file_cities, na = "")
  message("Data written to ", output_file_cities)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
