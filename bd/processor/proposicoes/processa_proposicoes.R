#' @title Processa dados das proposições
#' @description Processa os dados das proposições e retorna no formato correto para o banco de dados
#' @param proposicoes_data_path Caminho para o arquivo de dados das proposições sem tratamento
#' @return Lista contendo dois dataframes: Proposições e Proposições dos Parlamentares
processa_proposicoes <- function(proposicoes_data_path = here::here("crawler/raw_data/proposicoes.csv")) {
  library(tidyverse)
  library(here)
  
  proposicoes <- read_csv(proposicoes_data_path)

  proposicoes_alt <- proposicoes %>%
    mutate(      
      id_proposicao_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2), 
      id_proposicao),
      id_parlamentar_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2), 
      id_parlamentar))
  
  parlamentares_proposicoes_alt <- proposicoes_alt %>% 
    select(id_proposicao_voz, id_parlamentar_voz)
  
  proposicoes_alt <- proposicoes_alt %>% 
    select(id_proposicao_voz, id_proposicao, casa, nome, data_apresentacao, ementa, url) %>% 
    distinct()
  
  return(list(proposicoes_alt, parlamentares_proposicoes_alt))
}
