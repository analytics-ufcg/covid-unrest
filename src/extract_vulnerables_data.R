library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Data was obtained for May from http://www.portaltransparencia.gov.br/pagina-interna/603519-download-de-dados-auxilio-emergencial

load_vulnerable_data <- function(file) {
  read_csv(file, 
            col_types = "ccc", 
            col_names = c("uf","codigo_ibge_municipio","municipio"),
            locale = locale(encoding = "latin1")) %>% 
    janitor::clean_names()
}

process_vulnerable_states <- function(data_raw){
  state_codes = read_csv(here::here("data/ready/state-codes-ibge.csv"),
                         col_types = cols(.default = col_character(), 
                                          population2019 = col_double())) 
  
  data_raw %>%
    count(uf, name = "vulnerable_count") %>% 
    filter(!is.na(uf)) %>% 
    left_join(state_codes, by = c("uf" = "uf_sigla")) %>% 
    janitor::clean_names() %>% 
    mutate(vulnerable_prop = vulnerable_count / population2019) 
}

process_vulnerable_cities <- function(data_raw){
  city_codes = read_csv(here::here("data/ready/city-codes-ibge.csv"), 
                        col_types = cols(.default = col_character(), 
                                         population2019 = col_double())) 

  large_cities = city_codes %>% 
    filter(population2019 >= 250e3) 
  
  data_raw %>%
    count(codigo_ibge_municipio, name = "vulnerable_count") %>% 
    right_join(large_cities, by = c("codigo_ibge_municipio" = "municipio_code")) %>% 
    rename(municipio_code = codigo_ibge_municipio) %>% 
    mutate(vulnerable_prop = vulnerable_count / population2019) 
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("out/auxilio_emergencial-202004.csv")
  )
  
  output_file_cities <-
    here::here("data", "ready", "vulnerables-cities.csv")
  output_file_states <-
    here::here("data", "ready", "vulnerables-states.csv")
    
  data_raw <- load_vulnerable_data(input_file)
  data_states <- process_vulnerable_states(data_raw)
  data_cities <- process_vulnerable_cities(data_raw)
  
  write_csv(data_states, output_file_states, na = "")
  message("Data written to ", output_file_states)
  
  write_csv(data_cities, output_file_cities, na = "")
  message("Data written to ", output_file_cities)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
