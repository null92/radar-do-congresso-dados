#' @title Processa dados da autorias de proposições dos parlamentares
#' @description Processa os dados das autorias de proposições e retorna no formato correto para o banco de dados
#' @param proposicoes_data_path Caminho para o arquivo de dados das proposições sem tratamento
#' @param parlamentares_data_path  Caminho para o arquivo de dados dos parlamentares sem tratamento
#' @return Dataframe de Proposições dos Parlamentares
processa_parlamentares_proposicoes <- function(parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv"),
                                               proposicoes_data_path = here::here("crawler/raw_data/proposicoes.csv")) {
  library(tidyverse)
  library(here)
  
  proposicoes <- read_csv(proposicoes_data_path)
  
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
  
  parlamentares_proposicoes_alt <- parlamentares_proposicoes %>%
    select(id_proposicao_voz, id_parlamentar_voz, ordem_assinatura)
  
  return(parlamentares_proposicoes_alt)
}
