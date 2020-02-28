#!/usr/bin/env Rscript
source(here::here("crawler/votacoes/utils/constants.R"))
source(here::here("crawler/parlamentares/deputados/fetcher_deputado.R"))

# Bibliotecas
library(tidyverse)

#' @title Processa votos dos deputados
#' @description O processamento consiste em mapear as votações dos deputados (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes Dataframe com informações das votações para captura dos votos
#' @return Dataframe contendo dados de votos
#' @examples
#' processa_votos_camara(votacoes)
processa_votos_camara <- function(votacoes) {
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  source(here::here("crawler/votacoes/votos/fetcher_votos_camara.R"))
  
  votacoes_alt <- votacoes %>% 
    mutate(ano = str_extract(data_hora, "\\d{4}")) %>% 
    distinct(id_proposicao, ano)
  
  votos <- map2_df(votacoes_alt$id_proposicao, votacoes_alt$ano,
                   ~ fetch_votos_por_ano_camara(.x, .y))
  

  return(votos)
}

#' @title Processa votos dos parlamentares
#' @description O processamento consiste em mapear os votos dos parlamentares (caso tenha votado) e tratar os casos quando ele não votou
#' @param votacoes_datapath Caminho para o dataframe de votações
#' @return Dataframe contendo dados dos voto dos parlamentares
#' @examples
#' processa_votos()
processa_votos <- function(votacoes_datapath = here::here("crawler/raw_data/votacoes.csv")) {
  library(tidyverse)
  
  votacoes <- read_csv(votacoes_datapath)
  
  votacoes_camara <- votacoes %>% 
    dplyr::filter(casa == "camara")
  
  votacoes_senado <- votacoes %>% 
    dplyr::filter(casa == "senado")
  
  votos_camara <- processa_votos_camara(votacoes_camara) %>% 
    select(id_proposicao, id_votacao, id_parlamentar = id_deputado, casa, voto)
  
  votos_senado <- process_votos_senado(votacoes_senado) %>% 
    select(id_proposicao, id_votacao, id_parlamentar, casa, voto)
  
  votos <- rbind(votos_camara, votos_senado)
  
  return(votos)
}

#' @title Processa votos de plenário para um conjunto de votações com votos faltosos
#' @description Adiciona linhas com votos faltosos quando os senadores faltam às votações
#' @param votacoes Dataframe com as votações
#' @param votos Dataframe com os votos
#' @param senadores Dataframe com os dados dos senadores
#' @param mandatos Caminho para o dataframe com os dados de mandatos
#' @return Dataframe com os votos processados dos votos faltosos
processa_votacoes_com_votos_incompletos <- function(
  votacoes,
  votos,
  senadores,
  mandatos_senadores_datapath = here::here("crawler/raw_data/mandatos_senadores.csv")) {
  
  library(tidyverse)

  mandatos <- read_csv(mandatos_senadores_datapath)
  
  votacoes_incompletas <- votos %>% 
    count(id_votacao) %>% 
    filter(n < 81) %>% 
    pull(id_votacao) 
  
  votacoes_incompletas <- votacoes %>% 
    filter(id_votacao %in% votacoes_incompletas)
  
  senadores <- senadores %>% 
    select(id, nome_eleitoral, sg_partido, casa)
  
  votacoes_incompletas <-
    purrr::map2_df(votacoes_incompletas$id_votacao, votacoes_incompletas$data_hora, function(x, y) {
      
      votacao <- votos %>%
        filter(id_votacao %in% x)
        
      id_proposicao_votacao <-  votacao %>% 
        head(1) %>% 
        pull(id_proposicao)
      
      senadores_em_exercicio <- mandatos %>% 
        filter(data_inicio <= y, y <= data_fim | is.na(data_fim)) %>% 
        select(id_parlamentar)
      
      if (nrow(senadores_em_exercicio) == 81) {
        senadores_em_exercicio <- senadores %>% 
          filter(id %in% senadores_em_exercicio$id_parlamentar)
        
        votacao <- votacao %>% 
          select(-nome_eleitoral) %>% 
          right_join(senadores_em_exercicio, by=c("id", "casa")) %>% 
          mutate(partido = if_else(!is.na(partido), partido, sg_partido),
                 ano = if_else(is.na(ano), lubridate::year(y), ano),
                 id_proposicao = if_else(is.na(id_proposicao), id_proposicao_votacao, id_proposicao),
                 id_votacao = if_else(is.na(id_votacao), x, id_votacao),
                 voto = if_else(is.na(voto), 0 , voto)) %>% 
          select(-sg_partido)
      }
      
      return(votacao)
      
    })
  
  return(votacoes_incompletas)
}

#' @title Processa votos de plenário para um conjunto de votações
#' @description Recupera informação dos votos para um conjunto de votações no senado.
#' @param votacoes Dataframe de votações no senado.
#' @return Dataframe com os votos processados
#' @examples
#' votos <- process_votos_senado(votacoes)
process_votos_senado <- function(votacoes) {
  library(tidyverse)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  source(here::here("crawler/votacoes/votos/fetcher_votos_senado.R"))
  
  votos <- fetch_all_votos_senado(votacoes)
  
  senadores <- read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == "senado")
  
  votos_padronizados <- votos %>%
    enumera_voto() %>%
    mutate(partido = padroniza_sigla(partido),
           senador = str_remove(senador, "^\\s")) %>%
    select(ano, id_proposicao, id_votacao, senador, voto, partido, casa) %>%
    rename(nome_eleitoral = senador) %>%
    mapeia_nome_eleitoral_to_id_senado() 
  
  votos_finais <-
  rbind(votos_padronizados,
        processa_votacoes_com_votos_incompletos(votacoes,
                                                votos_padronizados,
                                                senadores)) %>%
  select(ano,
           id_proposicao,
           id_votacao,
           id_parlamentar = id,
           voto,
           partido,
           casa) %>% 
    distinct()
  
  return(votos_finais)
}
