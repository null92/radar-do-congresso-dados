#' @title Processa dados de proposições apresentadas na Câmara e no Senado
#' @description Baixa as proposições que foram aprensentadas na 56ª legislatura
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições apresentadas por deputados e senadores no Congresso em um ano
#' @examples
#' processa_dados_proposicoes(anos = c(2019, 2020))
processa_dados_proposicoes <- function(anos = c(2019, 2020)) {
  library(tidyverse)
  source(here::here("crawler/proposicoes/fetcher_proposicoes.R"))
  
  proposicoes <- fetcher_proposicoes_camara(anos) %>%
    rbind(fetcher_proposicoes_senado(anos))
  
  return(proposicoes)
}