#' @title Baixa dados da assiduidade dos deputados para uma lista de anos
#' @description Baixa os dados da assiduidade da legislatura atual para uma lista de anos
#' @param anos Lista de anos
#' @return Dataframe contendo informações da assiduidade
process_assiduidade <- function(anos = c(2019, 2020)) {
  library(tidyverse)
  source(here::here("crawler/parlamentares/assiduidade/fetcher_assiduidade_camara.R"))
  
  assiduidade <- fetch_assiduidade_camara(anos)
  
  return(assiduidade)
}