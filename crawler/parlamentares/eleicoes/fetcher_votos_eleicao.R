#' @title Captura votos de deputados federais em uma Eleição
#' @description Utiliza API do Datapedia para capturar votos recebidos por deputados federais nas eleições
#' @return Dataframe contendo votos dos deputados
#' @examples
#' fetch_votos_eleicao()
#' 
fetch_votos_eleicao <- function() {
  library(tidyverse)
  library(here)
  
  CARGO_DEPUTADO <- 6
  CARGO_SENADOR <- 5

  url <- paste0("https://eleicoes.datapedia.info/api/candidates/post/", codigo_cargo, ano, "/", uf, "/0")
  
  
  
}
