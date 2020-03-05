#' @title Recupera votos de um xml de votações a partir do código da sessão e da hora
#' @description Votos dos deputados a partir do código da sessão e da hora
#' @param cod_sessao Código da sessão da votação
#' @param hora Hora da sessão da votação
#' @param xml xml com votações
#' @return Votos dos parlamentares na votação específica
#' @examples
#' votos <- fetch_votos_por_sessao_camara("16821", "19:57", xml)
fetch_votos_por_sessao_camara <- function(cod_sessao, hora, xml) {
  library(tidyverse)
  library(xml2)
  
  votos <- xml_find_all(xml, paste0(".//Votacao[@codSessao = '",
                                    cod_sessao,"' and @Hora = '", hora,"']",
                                    "//votos//Deputado")) %>%
    map_df(function(x) {
      list(
        id_deputado = xml_attr(x, "ideCadastro"),
        voto = xml_attr(x, "Voto") %>%
          gsub(" ", "", .),
        partido = xml_attr(x, "Partido"))
    }) %>%
    select(id_deputado,
           voto,
           partido)
}

#' @title Recupera informações de votos de todas as votações de uma determinada proposição para um determinado ano
#' @description A partir do id da proposição e do ano recupera votos que aconteceram na Câmara dos Deputados
#' @param id_proposicao ID da proposição
#' @param ano Ano para o período de votações
#' @return Votos dos parlametares para a proposição (inclui várias votações)
#' @examples
#' votos <- fetch_votos_por_ano_camara(2190355, 2019)
fetch_votos_por_ano_camara <- function(id_proposicao, ano = 2019) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  source(here::here("crawler/votacoes/fetcher_votacoes_camara.R"))
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  if (is.na(id_proposicao)) {
    data <- tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido)
    return(data)
  }
  
  votos <- tryCatch({
    xml <- fetch_xml_api_votacao_camara(id_proposicao)
    
    votacoes_filtradas <- fetch_votacoes_por_ano_camara(id_proposicao, ano, xml) %>% 
      select(obj_votacao, data, cod_sessao, hora, id_votacao)
    
    votos_raw <- tibble(cod_sessao = votacoes_filtradas$cod_sessao,
                        hora = votacoes_filtradas$hora
    ) %>%
      mutate(dados = map2(
        cod_sessao,
        hora,
        fetch_votos_por_sessao_camara,
        xml
      )) %>% 
      unnest(dados)
    
    votos <- votos_raw %>% 
      mutate(partido = padroniza_sigla(partido)) %>% 
      enumera_voto() %>% 
      mutate(id_proposicao = id_proposicao,
             id_votacao = paste0(cod_sessao, str_remove(hora, ":")),
             casa = "camara") %>% 
      select(id_proposicao, id_votacao, id_deputado, voto, casa) %>% 
      distinct()
  }, error = function(e) {
    print(e)
    return(tribble(~ id_votacao, ~ id_deputado, ~ voto, ~ partido))
  })
  return(votos)
}