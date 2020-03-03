#' @title Processa dados de votos nas eleições
#' @description Processa os dados de votos nas eleições para deputados e senadores
#' @param votos_eleicoes_data_path Caminho para o arquivo de dados dos discursos
#' @return Dataframe com os dados de votos nas eleições prontos para serem inseridos no Banco de Dados
processa_votos_eleicao <- function(
  votos_eleicoes_data_path = here::here("crawler/raw_data/votos_eleicao.csv")) {
  library(tidyverse)
  library(here)
  source(here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  votos <- read_csv(votos_eleicoes_data_path, col_types = cols(.default = "c"))
  
  votos_partidos <- votos %>% 
    group_by(partido_eleicao) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(partido_eleicao)) %>% 
    ungroup()
  
  votos_alt <- votos %>%
    mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                       id)) %>%
    left_join(votos_partidos %>% select(id_partido, partido_eleicao), by = c("partido_eleicao")) %>% 
    select(id_parlamentar_voz, casa, ano, uf, id_partido, total_votos, total_votos_uf, proporcao_votos)
  
  return(votos_alt)
}
