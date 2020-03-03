#' @title Processa dados de votos nas eleições
#' @description Processa os dados de votos nas eleições para deputados e senadores
#' @param votos_eleicoes_data_path Caminho para o arquivo de dados dos discursos
#' @return Dataframe com os dados de votos nas eleições prontos para serem inseridos no Banco de Dados
processa_votos_eleicao <- function(
  votos_eleicoes_data_path = here::here("crawler/raw_data/votos_eleicao.csv")) {
  library(tidyverse)
  library(here)
  
  votos <- read_csv(votos_eleicoes_data_path, col_types = cols(.default = "c"))
  
  votos_alt <- votos %>%
    mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                       id)) %>%
    select(id_parlamentar_voz, casa, ano, total_votos, total_votos_uf, proporcao_votos)
  
  return(votos_alt)
}
