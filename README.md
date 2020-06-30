# Covid-19 and social unrest in Brasil

Data repo about this relationship. 

## Variables collected

Type and details [here](https://docs.google.com/spreadsheets/d/1uqR7Et1E2caMko_nzO1CZFLfgGMHBeDs2rubWdSOx0g/edit?usp=sharing).

### Covid data

**Source**: https://covid.saude.gov.br/ 

**Raw data**: `data/raw/HIST_PAINEL_COVIDBR_25jun2020.xlsx`

**Processing**: `src/extract_covid_data.R`

**Variables**: regiao,estado,coduf,data,semanaEpi,populacaoTCU2019,casosAcumulado,casosNovos,obitosAcumulado,obitosNovos,incidencia100k,mortalidade100k

### Excess/SARS deaths data

**Source**: https://brasil.io/dataset/covid19/obito_cartorio/?format=csv 

**Raw data**: `data/raw/obito_cartorio.csv`

**Processing**: `src/extract_cartorio_data.R`

**Variables**: state,epidemiological_week_2020,first_day_epiweek_2020,deaths_covid19_2020,deaths_other_respiratory_2019,deaths_other_respiratory_2020,deaths_others_2019,deaths_others_2020,deaths_total_2019,deaths_total_2020,deaths_total_dif,new_deaths_covid19_2020,new_deaths_other_respiratory_2019,new_deaths_other_respiratory_2020,new_deaths_others_2019,new_deaths_others_2020,new_deaths_total_2019,new_deaths_total_2020,new_deaths_total_dif

### Restrictiveness of gov response

**Source**: https://github.com/OxCGRT/Brazil-covid-policy 

**Raw data**: `data/raw/OxCGRT_Brazil_Subnational_31May2020.csv`

**Processing**: `src/extract_measures_data.R`

**Variables**: uf,city_name,city_code,date,stringency_index

### Degree of social isolation

Daily percentage change wrt March 2-8th.

**Source**: https://github.com/EL-BID/IDB-IDB-Invest-Coronavirus-Impact-Dashboard 

**Raw data**: `data/raw/waze_idb.csv`

**Processing**: `src/extract_congestion_data.R`

**Variables**: week_number,region_type,region_name,ratio_congestion,percentage_congestion_change
