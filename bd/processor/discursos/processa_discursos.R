#' @title Processa dados de discursos
#' @description Processa os dados de discursos de deputados e senadores
#' @param discursos_data_path Caminho para o arquivo de dados dos discursos
#' @return Dataframe com os dados de discursos prontos para serem inseridos no Banco de Dados
processa_discursos <- function(
  discursos_data_path = here::here("crawler/raw_data/discursos.csv")) {
  library(tidyverse)
  library(here)
  
  discursos <- read_csv(discursos_data_path, col_types = cols(.default = "c"))
  
  discursos_alt <- discursos %>%
    mutate(resumo = trimws(resumo, which = "both")) %>% 
    mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                       id_parlamentar)) %>% 
    rowid_to_column(var = "id_discurso") %>% 
    select(id_discurso, id_parlamentar_voz, casa, tipo, data, local, resumo, link)

  return(discursos_alt)
}
