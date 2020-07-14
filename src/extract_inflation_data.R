library(dplyr, quietly = TRUE, warn.conflicts = FALSE)
library(janitor, quietly = TRUE, warn.conflicts = FALSE)
library(readr, quietly = TRUE)
library(here, quietly = TRUE, warn.conflicts = FALSE)

# Data was obtained for june from https://sidra.ibge.gov.br/tabela/7060#/n1/all/n7/all/n6/all/v/69/p/202006/c315/all/d/v69%202/l/,p+t+v,c315/resultado

load_ipca_data <- function(file) {
  read_csv2(file, 
            col_types = "cd",
           locale = locale(decimal_mark = ",")) %>% 
    janitor::clean_names()
}

process_ipca_cities <- function(raw){
  chave_municipio = function(nome, uf){
    nome_l = stringi::stri_trans_general(nome, "Latin-ASCII") 
    str_to_lower(str_glue("{nome_l}-{uf}"))
  }
  
  city_codes = read_csv(here::here("data/ready/city-codes-ibge.csv"), 
                        col_types = cols(.default = col_character())) %>% 
    mutate(chave = chave_municipio(municipio_name, uf_sigla))
  
  raw %>%
    mutate(regiao = if_else(regiao == "Grande Vitória (ES)", "Vitória (ES", regiao)) %>%  
    separate(regiao, into = c("municipio_name", "uf_sigla"), sep = "[()]") %>% 
    mutate_at(vars(municipio_name, uf_sigla), str_trim) %>% 
    mutate(chave = chave_municipio(municipio_name, uf_sigla)) %>%
    select(-municipio_name, -uf_sigla) %>% 
    left_join(city_codes, by = c("chave")) %>% 
    select(-chave)
}

main <- function(argv = NULL) {
  input_file <- ifelse(
    length(argv) >= 1,
    argv[1],
    here::here("data/raw/ipca_acumulado.csv")
  )
  
  output_file_cities <-
    here::here("data", "ready", "ipca-cities.csv")
    
  data_raw <- load_ipca_data(input_file)
  data_cities <- process_ipca_cities(data_raw)
  
  write_csv(data_cities, output_file_cities, na = "")
  message("Data written to ", output_file_cities)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
