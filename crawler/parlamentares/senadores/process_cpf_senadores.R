#' @title Recupera os cpfs dos senadores
#' @description Recebe um caminho para o dataset de candidatos e o dataset de parlamentares, e une os parlamentares com os
#' dados da eleição a fim de extrair o CPF para os senadores.
#' @param parlamentares_datapath Caminho para arquivo de parlamentares
#' @param candidatos_2018_data_path Caminho para o arquivo de candidatos em 2018
#' @param candidatos_2014_data_path Caminho para o arquivo de candidatos em 2014
#' @return Dataframe contendo id e CPF dos senadores
process_cpf_parlamentares_senado <- function(
  parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv"),
  candidatos_2018_datapath = here::here("crawler/raw_data/dados_tse/consulta_cand_2018_BRASIL.csv.zip"),
  candidatos_2014_datapath = here::here("crawler/raw_data/dados_tse/consulta_cand_2014_BRASIL.csv.zip")) {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/utils/utils.R"))
  source(here::here("crawler/parlamentares/patrimonio/read_tse_data.R"))
  
  parlamentares <- read_csv(parlamentares_datapath, col_types = cols(id = "c"))
  
  candidatos_2018 <- import_candidatos_tse(candidatos_2018_datapath)
  
  candidatos_2014 <- import_candidatos_tse(candidatos_2014_datapath)
  
  candidatos <- candidatos_2018 %>% 
    rbind(candidatos_2014) %>% 
    mutate(ds_cargo = str_to_title(ds_cargo)) %>% 
    mutate(nm_candidato = gsub("-", " ", nm_candidato)) %>% 
    filter(ds_cargo %in% c("Senador", "1º Suplente", "2º Suplente")) %>% 
    select(nm_candidato, cpf_candidato)
  
  parlamentares <- parlamentares %>% 
    filter(casa == "senado") %>% 
    select(id, nome_civil)
  
  senadores_com_cpf <- parlamentares %>% 
    mutate(nome_padronizado = padroniza_nome(nome_civil)) %>% 
    left_join(candidatos %>% 
                 mutate(nome_padronizado = padroniza_nome(nm_candidato)), 
               by = c("nome_padronizado")) %>% 
    select(id, 
           cpf = cpf_candidato,
           nome_civil) %>% 
    distinct()
  
  return(senadores_com_cpf)
}
