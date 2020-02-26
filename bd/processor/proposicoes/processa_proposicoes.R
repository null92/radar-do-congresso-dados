#' @title Processa dados das proposições
#' @description Processa os dados das proposições e retorna no formato correto para o banco de dados
#' @param proposicoes_data_path Caminho para o arquivo de dados das proposições sem tratamento
#' @param parlamentares_data_path  Caminho para o arquivo de dados dos parlamentares sem tratamento
#' @param proposicoes_votadas_data_path  Caminho para o arquivo de dados das proposições com votações
#' mas sem tratamento
#' @return Dataframe de Proposições autoradas por parlamentares e/ou votadas na leg.
processa_proposicoes <- function(parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv"),
                                 proposicoes_data_path = here::here("crawler/raw_data/proposicoes.csv"),
                                 proposicoes_votadas_data_path = here::here("crawler/raw_data/proposicoes_votadas.csv")) {
  library(tidyverse)
  library(here)
  
  proposicoes <- read_csv(proposicoes_data_path)
  proposicoes_votadas <- read_csv(proposicoes_votadas_data_path)
  
  proposicoes_alt <- proposicoes %>%
    mutate(
      id_proposicao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2),
                                 id_proposicao),
      id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2),
                                  id_parlamentar)
    )
  
  parlamentares_id <- read_csv(parlamentares_data_path) %>%
    pull(id)
  
  parlamentares_proposicoes <- proposicoes_alt %>%
    filter(id_parlamentar %in% parlamentares_id)
  
  proposicoes_alt <- proposicoes_alt %>%
    filter(id_proposicao %in% parlamentares_proposicoes$id_proposicao) %>%
    select(id_proposicao_voz, id_proposicao, casa, nome, ano, ementa, url)
  
  proposicoes_votadas_alt <- proposicoes_votadas %>%
    mutate(id_proposicao_voz = paste0(dplyr::if_else(casa == "camara", 1, 2),
                                      id_proposicao))
  
  proposicoes_alt <-
    bind_rows(proposicoes_alt, proposicoes_votadas_alt) %>%
    select(id_proposicao_voz, id_proposicao, casa, nome, ano, ementa, url) %>%
    distinct()
  
  return(proposicoes_alt)
}