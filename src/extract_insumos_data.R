library(dplyr)
library(here)
library(readr)

main <- function(argv) {
  input_csv <- ifelse(length(argv) >= 1, tolower(argv[1]), 
                      here("data", "raw", "lista_insumos_e_leitos.csv"))
  output_csv <- ifelse(length(argv) >= 2, argv[2],
                       here("data", "ready", "covid-insumos.csv"))
  
  insumos <- read_csv2(input_csv, col_types = cols())
  insumos_filt <- insumos %>%
    select(
      estado = 1,
      leitos_locados = `Leitos locados`,
      leitos_uti_adulto = `Leitos UTI adulto`,
      leitos_uti_adulto_sus = `UTI adulto SUS`,
      leitos_uti_adulto_nao_sus = `Uti adulto não SUS`,
      leitos_uti_habilitados = `Leitos UTI habilitados`,
      mascaras_n95 = `Mascara N95`)
  
  write_csv(insumos_filt, output_csv)
}

if (!interactive()) {
  argv <- commandArgs(TRUE) 
  main(argv)
}
