# Covid-19 and social unrest in Brasil

Data repo about this relationship. 

## Variables collected

Type and details [here](https://docs.google.com/spreadsheets/d/1uqR7Et1E2caMko_nzO1CZFLfgGMHBeDs2rubWdSOx0g/edit?usp=sharing).



### Covid data

**Source**: https://covid.saude.gov.br/ 

**Raw data**: `data/raw/HIST_PAINEL_COVIDBR_30jun2020.xlsx`

**Processing**: `src/extract_covid_data.R`

**Variables**: regiao,estado,municipio,cod_uf,cod_municipio,cod_regiao_saude,nome_regiao_saude,data,semana_epi,populacao_tcu2019,casos_acumulado,casos_novos,obitos_acumulado,obitos_novos,interior_metropolitana,incidencia100k,mortalidade100k

### Excess/SARS deaths data

**Source**: https://brasil.io/dataset/covid19/obito_cartorio/?format=csv 

**Raw data**: `data/raw/obito_cartorio.csv`

**Processing**: `src/extract_cartorio_data.R`

**Variables**: state,epidemiological_week_2020,first_day_epiweek_2020,deaths_covid19_2020,deaths_other_respiratory_2019,deaths_other_respiratory_2020,deaths_others_2019,deaths_others_2020,deaths_total_2019,deaths_total_2020,deaths_total_dif,new_deaths_covid19_2020,new_deaths_other_respiratory_2019,new_deaths_other_respiratory_2020,new_deaths_others_2019,new_deaths_others_2020,new_deaths_total_2019,new_deaths_total_2020,new_deaths_total_dif

### COVID beds occupancy rate

Fraction of beds occupancy per state for a single day.

**Source**: Projeto Mandacaru spreadsheet (closed)

**Raw data**: `data/raw/planilha_projeto_mandacaru.xlsx`

**Processing**: `src/extract_bed_occupancy_data.R`

**Variables**: date,state,icu_beds_occupancy,hospital_beds_occupancy

### COVID insumos e leitos

Number of COVID beds and masks per state

**Source**: https://covid-insumos.saude.gov.br/paineis/insumos/painel.php

**Raw data**: `data/raw/lista_insumos_e_leitos.csv`

**Processing**: `src/extract_insumos_data.R`

**Variables**: estado,leitos_locados,leitos_uti_adulto,leitos_uti_adulto_sus,leitos_uti_adulto_nao_sus,leitos_uti_habilitados,mascaras_n95

### IBGE ICU beds, physicians and nurses

Number of ICU beds, physicians and nurses in 2019

**Raw data**: `data/ready/Leitos_de_UTI_em_2019.csv`, `data/ready/Medicos_por_municipio_2019.csv`, `data/ready/Enfermeiros_em_2019.csv`

**Processing**: `src/extract_ibge_saude_data.R`

**Variables**: estado,cod_municipio_ibge,nome_municipio,regiao,populacao,leitos_uti_total,leitos_uti_100k_hab,leitos_uti_sus_total,leitos_uti_sus_100k_hab,medicos_total,medicos_sus,medicos_100k_hab,medicos_sus_100k_hab,enfermeiros_total,enfermeiros_sus,enfermeiros_100k_hab,enfermeiros_sus_100k_hab

===

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

## Governmental Transparency on Covid Data

Transparency index by Open knowledge

**Source**: https://transparenciacovid19.ok.org.br/ 

**Raw data**: `data/raw/ok-covid-transparency.csv`

**Processing**: `src/extract_transparency_data.R`

**Variables**: uf,date,index

## Polarization 

Support for extreme-right wing presidential candidate in 2018, by Datapedia (primary source is TSE).

**Source**: https://eleicoes.datapedia.info 

**Raw data**: `data/raw/bolsonaro-votes-cities.json`, `data/raw/bolsonaro-votes-states.json`

**Processing**: `src/extract_voting_data.R` 

**Variables**: state,state_code,proportion_bolsonaro or city,city_code,proportion_bolsonaro


## Social Capital

Number of NGOs per state. 

**Source**: Receita Federal

**Raw data**: `data/raw/empresas-classe-94308.csv.zip`

**Processing**: `src/extract_ngo_data.R` 

**Variables for cities**: uf,ngo_count,populacao_tcu2019,uf_code,uf_name,municipio_code_short,municipio_code,municipio_name,regiao_code,regiao_sigla,regiao_name,ngo_1k_hab

**Variables for states**: uf,ngo_count,uf_code,uf_name,regiao_code,regiao_sigla,regiao_name


## Vulnerable Population

Count and proportion of population receiving Auxílio Emergencial per state and city.

**Source**: [Brasil.io](http://www.portaltransparencia.gov.br/pagina-interna/603519-download-de-dados-auxilio-emergencial)

**Variables for cities**: municipio_code,vulnerable_count,uf_sigla,uf_code,municipio_code5,municipio_name,population2019,municipio_code6,regiao_code,regiao_sigla,regiao_name,vulnerable_pro

**Variables for states**: uf,vulnerable_count,uf_code,regiao_code,regiao_sigla,regiao_name,population2019,vulnerable_prop


## Inflation Data

Accumulated IPCA between jan and july 2020 for the urban regions IBGE follows. 

**Source**: [Sidra, from IBGE](https://sidra.ibge.gov.br/tabela/7060#/n1/all/n7/all/n6/all/v/69/p/202006/c315/all/d/v69%202/l/,p+t+v,c315/resultado)

**Variables**: ipca_acumulado, uf_sigla, uf_code, municipio_code5, municipio_name, population2019, municipio_code6, municipio_code, regiao_code, regiao_sigla, regiao_name