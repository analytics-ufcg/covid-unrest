library(dplyr)
library(here)
library(readr)

# Leitos por municipio
leitos <- read_csv(here("data", "raw", "Leitos_de_UTI_em_2019.csv"),
                   col_types = cols()) %>%
  select(estado = Nome_Estado, cod_municipio_ibge = Codigo_Municipio,
         nome_municipio = Nome_municipio, regiao = GR, populacao = Pop_Total,
         leitos_uti_total = Leitos_UTI_Total,
         leitos_uti_100k_hab = Leitos_UTI_100mil_hab_Ind,
         leitos_uti_sus_total = Leitos_UTI_SUS_Total,
         leitos_uti_sus_100k_hab = Leitos_UTI_SUS_100mil_hab_Ind)
  
# Medicos por municipio
medicos <- read_csv(here("data", "raw", "Medicos_por_municipio_2019.csv")) %>%
  select(estado = Nome_Estado, cod_municipio_ibge = Codigo_Municipio,
         nome_municipio = Nome_municipio, regiao = GR, populacao = Pop_Total,
         medicos_total = Total_Medicos,
         medicos_sus = Medicos_SUS,
         medicos_100k_hab = Medicos_100mil_hab_Ind,
         medicos_sus_100k_hab = Medicos_SUS_100mil_hab_Ind)

# Enfermeiros por municipio
enfermeiros <- read_csv(here("data", "raw", "Enfermeiros_em_2019.csv")) %>%
  select(estado = Nome_Estado, cod_municipio_ibge = Codigo_Municipio,
         nome_municipio = Nome_municipio, regiao = GR, populacao = Pop_Total,
         enfermeiros_total = Total_Enfermeiros,
         enfermeiros_sus = Enfermeiros_SUS,
         enfermeiros_100k_hab = Enfermeiros_100mil_hab_Ind,
         enfermeiros_sus_100k_hab = Enfermeiros_SUS_100mil_hab_Ind)

leitos %>%
  full_join(medicos) %>%
  full_join(enfermeiros) %>%
  write_csv(here("data", "ready", "leitos_medicos_enfermeiros_2019.csv"))
