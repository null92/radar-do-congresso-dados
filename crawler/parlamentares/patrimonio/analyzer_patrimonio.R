#' @title Processa dados de bens
#' @description Processa dados de bens declarados ao TSE para deputados e senadores da legislatura 56
#' @return Dataframe contendo informações dos bens de deputados e senadores
#' @examples
#' process_bens_parlamentares()
#' 
process_bens_parlamentares <- function() {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/senadores/process_cpf_senadores.R"))
  options(scipen = 999)
  
  bens_candidatos <- processa_bens_candidatos_congresso()
  
  parlamentares <- read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c"))
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador)
  
  parlamentares_bens <- parlamentares %>% 
    select(id_parlamentar = id, nome_eleitoral, cpf, casa) %>% 
    left_join(bens_candidatos, by = c("cpf" = "cpf_candidato"))
  
  ## Recupera patrimônio dos senadores eleitos em 2014
  parlamentares_senadores_2014 <- parlamentares_bens %>% 
    filter(casa == "senado") %>% 
    filter(is.na(ano_eleicao)) %>% 
    select(id_parlamentar, nome_eleitoral, cpf, casa) %>% 
    left_join(processa_bens_candidatos_senadores_2014(), by = c("cpf" = "cpf_candidato"))
  
  parlamentares_bens_merge <- parlamentares_bens %>% 
    rbind(parlamentares_senadores_2014) %>% 
    filter(!is.na(ano_eleicao)) ## filtra quem não tem patrimônio declarado
    
  return(parlamentares_bens_merge) 
}

#' @title Processa dados de bens para candidatos a deputado federal e ao Senado em 2018
#' @description Processa dados de bens declarados ao TSE para candidatos a deputado federal e ao Senado em 2018
#' @return Dataframe contendo informações dos bens de candidatos
#' @examples
#' processa_bens_candidatos_congresso()
#'
processa_bens_candidatos_congresso <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/patrimonio/read_tse_data.R"))
  
  candidatos_2018 <- import_candidatos_tse(here::here("crawler/raw_data/dados_tse/consulta_cand_2018_BRASIL.csv.zip"))
  
  bens_2018 <- import_patrimonio_tse(here::here("crawler/raw_data/dados_tse/bem_candidato_2018_BRASIL.csv.zip"))
  
  bens <- bens_2018 %>% 
    select(sq_candidato, ano_eleicao, ds_tipo_bem, ds_bem, valor_bem) %>% 
    inner_join(candidatos_2018 %>%
                 filter(ds_cargo %in% c("DEPUTADO FEDERAL", "SENADOR", "1º SUPLENTE", "2º SUPLENTE")) %>% 
                 select(sq_candidato, partido_eleicao = sg_partido, cpf_candidato, ds_cargo),
               by = c("sq_candidato"))
  
  return(bens)
}

#' @title Processa dados de bens para candidatos ao Senado em 2014
#' @description Processa dados de bens declarados ao TSE para candidatos ao Senado em 2014
#' @return Dataframe contendo informações dos bens de candidatos
#' @examples
#' processa_bens_candidatos_senadores_2014()
#'
processa_bens_candidatos_senadores_2014 <- function() {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/patrimonio/read_tse_data.R"))
  
  candidatos_2014 <- import_candidatos_tse(here::here("crawler/raw_data/dados_tse/consulta_cand_2014_BRASIL.csv.zip"))
  
  bens_2014 <- import_patrimonio_tse(here::here("crawler/raw_data/dados_tse/bem_candidato_2014_BRASIL.csv.zip"))
  
  bens_senadores_2014 <- bens_2014 %>% 
    select(sq_candidato, ano_eleicao, ds_tipo_bem, ds_bem, valor_bem) %>% 
    inner_join(candidatos_2014 %>%
                 filter(ds_cargo %in% c("SENADOR", "1º SUPLENTE", "2º SUPLENTE")) %>% 
                 select(sq_candidato, partido_eleicao = sg_partido, cpf_candidato, ds_cargo),
               by = c("sq_candidato"))
  
  return(bens_senadores_2014)
}

