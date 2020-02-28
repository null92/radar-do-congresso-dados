#' @title Processa dados de votos
#' @description Processa os dados de votos e retorna no formato  a ser utilizado pelo banco de dados
#' @param votos_posicoes_data_path Caminho para o arquivo de dados de votos
#' @param votacoes_data_path Caminho para o arquivo de dados de votações
#' @param parlamentares_path Caminho para o arquivo de dados de parlamentares
#' @return Dataframe com informações das votos
processa_votos <- function(votos_data_path = here::here("crawler/raw_data/votos.csv"),
                           votacoes_data_path = here::here("bd/data/votacoes.csv"),
                           parlamentares_path = here::here("bd/data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  votos <- read_csv(votos_data_path, col_types = cols(id_parlamentar = "c")) %>% 
    select(id_votacao, id_parlamentar, casa, voto)
  
  votacoes <- read_csv(votacoes_data_path) %>%
    distinct(id_votacao) %>% 
    pull(id_votacao)
  
  parlamentares <- read_csv(parlamentares_path, col_types = cols(id_parlamentar_voz = "c")) %>% 
    pull(id_parlamentar_voz)
  
  votos_select <- votos %>%
    mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                              id_parlamentar)) %>% 
    filter(id_votacao %in% votacoes, id_parlamentar_voz %in%  parlamentares) %>% 
    select(id_votacao, id_parlamentar_voz, voto)
  
  return(votos_select)
}
