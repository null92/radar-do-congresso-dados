#' @title Recupera xml com votos
fetch_xml_api_votos_camara <- function(id_votacao) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/votacoes/",id_votacao,"/votos")
  
  print(paste0("Baixando votos da votação id ", id_votacao))
  
  #xml <- RCurl::getURL(url) %>% xml2::read_xml()
  json <- (RCurl::getURL(url) %>% jsonlite::fromJSON())$dados %>% as_tibble()

  return(json)
}

#' @title Recupera informações de votos de cada votação
fetch_votos_por_votacao_camara <- function(id_votacao,id_proposicao) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  if (is.na(id_proposicao) || is.na(id_votacao)) {
    data <- tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  }
  
  votos <- tryCatch({
    json <- fetch_xml_api_votos_camara(id_votacao)

    votos <- json %>%
      mutate(
        id_deputado = deputado_$id,
        partido = deputado_$siglaPartido,
        voto = tipoVoto
      ) %>%
      mutate(partido = padroniza_sigla(partido)) %>% 
      enumera_voto() %>% 
      mutate(id_proposicao = id_proposicao,
             id_votacao = id_votacao,
             casa = "camara") %>% 
      select(id_proposicao, id_votacao, id_deputado, voto, casa) %>% 
      distinct()
  }, error = function(e) {
    print(e)
    return(tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido))
  })
  return(votos)
}