#' @title Processa votos recebidos por candidatos a Deputado federal (2018) e Senador (2014 e 2018)
#' @description Utiliza API do Datapedia para capturar votos recebidos por candidatos a deputado federal e senador
#' @return Dataframe contendo informações dos candidatos e os votos recebidos na eleição
#' @examples
#' process_votos_eleicao_congresso()
#' 
process_votos_eleicao_congresso <- function() {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/eleicoes/fetcher_votos_eleicao.R"))
  
  CARGO_DEPUTADO <- 6
  CARGO_SENADOR <- 5
  
  ## Eleições de 2018
  candidatos_2018 <- fetch_votos_eleicao(c(CARGO_DEPUTADO, CARGO_SENADOR), 2018)
  
  candidatos_2014 <- fetch_votos_eleicao(c(CARGO_SENADOR), 2014)
  
  candidatos <- candidatos_2018 %>% 
    rbind(candidatos_2014)
  
  return(candidatos)
}

#' @title Processa votos totais válidos por UF, cargo e Eleição.
#' @description Utiliza API do Datapedia para capturar votos válidos por UF, cargo e Eleição
#' @param candidatos Dataframe de candidatos
#' @return Dataframe contendo informações dos votos válidos
#' @examples
#' process_votos_totais_uf()
#' 
process_votos_totais_uf <- function(candidatos) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/eleicoes/fetcher_votos_eleicao.R"))
  
  candidatos_group <- candidatos %>% 
    group_by(uf, id_eleicao, codigo_cargo) %>% 
    summarise(id_candidato_exemplo = first(id_datapedia)) %>% 
    ungroup()
  
  votos_uf <- pmap_dfr(list(candidatos_group$uf, 
                            candidatos_group$id_eleicao, 
                            candidatos_group$id_candidato_exemplo,
                            candidatos_group$codigo_cargo),
                       ~ fetch_total_votos_uf(..1, ..2, ..3, ..4))
  
  map_id_eleicao_ano <- candidatos %>% 
    count(ano, id_eleicao) %>% 
    ungroup()
  
  votos_uf_selected <- votos_uf %>% 
    left_join(map_id_eleicao_ano %>% select(ano, id_eleicao), by = c("id_eleicao")) %>% 
    select(uf, ano, codigo_cargo = post_id, total_votos_uf)
  
  return(votos_uf_selected)
}

#' @title Processa votos recebidos pelos parlamentares (deputados e senadores) que participaram da legislatura 56
#' @description Processa votos recebidos por parlamentares da legislatura 56
#' @return Dataframe contendo informações dos candidatos e os votos recebidos na eleição
#' @examples
#' process_votos_parlamentares()
#' 
process_votos_parlamentares <- function() {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/senadores/process_cpf_senadores.R"))
  options(scipen = 999)
  
  parlamentares <- read_csv(here::here("crawler/raw_data/parlamentares.csv"), col_types = cols(id = "c"))
  
  ids_senadores <- process_cpf_parlamentares_senado() %>% 
    select(id_senador = id, cpf_senador = cpf)
  
  parlamentares <- parlamentares %>% 
    left_join(ids_senadores, by = c("id" = "id_senador")) %>% 
    mutate(cpf = if_else(casa == "senado", cpf_senador, cpf)) %>% 
    select(-cpf_senador)
  
  candidatos <- process_votos_eleicao_congresso()
  
  candidatos_group <- process_votos_totais_uf(candidatos)
  
  candidatos_computed <- candidatos %>% 
    left_join(candidatos_group, by = c("uf", "ano", "codigo_cargo")) %>% 
    mutate(proporcao_votos = total_votos / total_votos_uf) %>% 
    mutate(proporcao_votos = if_else(is.na(proporcao_votos), 0, proporcao_votos)) %>% 
    select(ano, cpf, nome, uf, partido_eleicao, total_votos, total_votos_uf, proporcao_votos)
  
  parlamentares_alt <- parlamentares %>% 
    select(id, casa, cpf, nome_eleitoral, condicao_eleitoral, em_exercicio) %>% 
    left_join(candidatos_computed %>% filter(ano == 2018), by = c("cpf"))
  
  parlamentares_2014 <- parlamentares_alt %>% 
    filter(casa == "senado", is.na(total_votos)) %>% 
    select(id, casa, cpf, nome_eleitoral, condicao_eleitoral, em_exercicio) %>% 
    left_join(candidatos_computed %>% filter(ano == 2014), by = c("cpf"))
  
  parlamentares_merge <- parlamentares_alt %>%
    filter(!is.na(total_votos)) %>% 
    rbind(parlamentares_2014) %>% 
    distinct() %>% 
    filter(!is.na(total_votos))
  
  return(parlamentares_merge)
}
