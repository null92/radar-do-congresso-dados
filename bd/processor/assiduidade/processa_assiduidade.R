#' @title Processa dados de assiduidade
#' @description Processa os dados de assiduidade e retorna no formato a ser utilizado pelo banco de dados
#' @param assiduidade_data_path Caminho para o arquivo de dados de assiduidade
#' @return Dataframe com informações das assiduidades
processa_assiduidade <- function(assiduidade_data_path = here::here("crawler/raw_data/assiduidade.csv")) {
  library(tidyverse)
  library(here)
  
  assiduidade <- read_csv(assiduidade_data_path)
  
  assiduidade_alt <-  assiduidade %>%
    mutate(id_parlamentar_voz = paste0(dplyr::if_else(casa == "camara", 1, 2), 
                                       id_parlamentar)) %>% 
    select(id_parlamentar_voz, ano, casa, dias_com_sessoes_deliberativas, dias_presentes, dias_ausencias_justificadas, dias_ausencias_nao_justificadas)
  
  return(assiduidade_alt)
}