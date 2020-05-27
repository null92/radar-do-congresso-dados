#' @title Processa dados de discursos da Câmara e do Senado
#' @description Recupera dados de discursos da Câmara e do Senado na legislatura atual
#' @return Dataframe contendo informações dos discursos
#' @examples
#' processa_dados_discursos()
processa_dados_discursos <- function() {
  library(tidyverse)
  source(here::here("crawler/parlamentares/discursos/fetcher_discursos_camara.R"))
  source(here::here("crawler/parlamentares/discursos/fetcher_discursos_senado.R"))
  
  discursos_camara <- fetch_discursos_todos_deputados()
  
  discursos_senado <- fetch_discursos_todos_senadores()
  
  discursos <- discursos_camara %>%
    rbind(discursos_senado) %>% 
    select(-id_discurso)
  
  return(discursos)
}
