#' @title Processa dados do patrimônio dos parlamentares
#' @description Processa os dados de patriônio dos parlamentares e retorna no formato correto para o banco de dados
#' @param patrimônio_datapath Caminho para o arquivo de dados de patrimônio sem tratamento
#' @return Dataframe com informações detalhadas dos patrimônios
processa_patrimonio <- function(patrimonio_datapath = here::here("crawler/raw_data/patrimonio_parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  patrimonio <- read_csv(patrimonio_datapath, col_types = cols(valor_bem = "d", .default = "c"))
  
  patrimonio_alt <- patrimonio %>%
    mutate(id_parlamentar_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2), 
      id_parlamentar)) %>% 
    tibble::rowid_to_column(var = "id_patrimonio") %>% 
    select(id_patrimonio, id_parlamentar_voz, casa, ano_eleicao, ds_cargo, ds_tipo_bem, ds_bem, valor_bem)
  
  return(patrimonio_alt)
}
