

# devtools::install_github("tbrugz/ribge")
library(ribge)
library(tidyverse)

raw <- populacao_municipios(2019)

pop2019 = raw %>%
  select(-populacao_str) %>%
  rename(
    municipio_code5 = codigo_munic,
    municipio_code = cod_municipio,
    municipio_code6 = cod_munic6,
    population2019 = populacao,
    municipio_name = nome_munic,
    uf_sigla = uf,
    uf_code = codigo_uf
  )

regions = read_csv(here::here("data/ready/ibge-regions.csv"), col_types = "cccc")

pop2019 %>%
  left_join(regions, by = "municipio_code") %>% 
  write_csv(here::here("data/ready/city-codes-ibge.csv"))

pop2019 %>%
  left_join(regions, by = "municipio_code") %>% 
  group_by(uf_sigla, uf_code, regiao_code, regiao_sigla, regiao_name) %>%
  summarise(population2019 = sum(population2019)) %>% 
  write_csv(here::here("data/ready/state-codes-ibge.csv"))
