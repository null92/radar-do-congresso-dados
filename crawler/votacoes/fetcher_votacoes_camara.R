#' @title Recupera xml com votações de uma proposição específica
#' @description A partir do id da prosição recupera o xml com as votações em plenário da proposição
#' @param id_proposicao ID da proposição
#' @return XML com as votações da proposição
#' @examples
#' votacoes_mpv8712019 <- fetch_xml_api_votacao_camara(2190355)
fetch_xml_api_votacao_camara <- function(id_proposicao) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  proposicao <- get_sigla_by_id_camara(id_proposicao) %>%
    select(siglaTipo, numero, ano)
  
  url <- paste0("https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ObterVotacaoProposicao?tipo=",
                proposicao$siglaTipo, "&numero=", proposicao$numero, "&ano=", proposicao$ano)
  
  print(paste0("Baixando votação da ", proposicao$siglaTipo, " ", proposicao$numero, "/", proposicao$ano))
  
  xml <- getURL(url) %>%
    read_xml()
  
  return(xml)
}

#' @title Recupera informações de votações a partir de um xml
#' @description A partir do xml das votações recupera dados de todas as votações disponíveis
#' @param id_proposicao ID da proposição
#' @param xml xml com votações. Se Null então o xml é carregado
#' @return Info sobre as votações
#' @examples
#' votacoes_mpv8712019 <- fetch_votacoes_por_proposicao_camara(2190355, xml)
fetch_votacoes_por_proposicao_camara <- function(id_proposicao, xml = NULL) {
  library(tidyverse)
  library(xml2)
  
  tryCatch({
    if (is.null(xml)) {
      xml <- fetch_xml_api_votacao_camara(id_proposicao)
    }
    
    votacoes <- xml_find_all(xml, ".//Votacao") %>%
      map_df(function(x) {
        list(
          obj_votacao = xml_attr(x, "ObjVotacao"),
          resumo = xml_attr(x, "Resumo"),
          cod_sessao = xml_attr(x, "codSessao"),
          hora = xml_attr(x, "Hora"),
          data = as.Date(xml_attr(x, "Data"), "%d/%m/%Y")
        )
      })
  }, error = function(e) {
    data <- tribble(~ obj_votacao, ~ resumo, ~ cod_sessao, ~ hora, ~ data)
    return(data)
  })

  return(votacoes)
}

#' @title Recupera informações das votações de uma determinada proposição para um determinado ano
#' @description A partir do id da proposição e do ano recupera dados de votações que aconteceram na Câmara dos Deputados
#' @param id_proposicao ID da proposição
#' @param ano Ano para o período de votações
#' @return Votações da proposição em um ano
#' @examples
#' votacoes <- fetch_votacoes_por_ano_camara(2190355, 2019)
fetch_votacoes_por_ano_camara <- function(id_proposicao, ano = 2019, xml = NULL) {
  library(tidyverse)
  source(here::here("crawler/votacoes/utils_votacoes.R"))
  
  votacoes <- tryCatch({
    if (is.null(xml)) {
      xml <- fetch_xml_api_votacao_camara(id_proposicao)
    }
    
    votacoes <- fetch_votacoes_por_proposicao_camara(id_proposicao, xml)
    
    votacoes <- votacoes %>% 
      mutate(ano_votacao = format(data, "%Y")) %>% 
      filter(ano_votacao == ano) %>% 
      mutate(id_votacao = paste0(cod_sessao, str_remove(hora, ":")),
             id_proposicao = id_proposicao) %>% 
      select(id_proposicao, obj_votacao, data, cod_sessao, hora, id_votacao)
    
  }, error = function(e){
    return(
      tribble(~id_proposicao, ~ obj_votacao, ~ data, ~ cod_sessao, ~ hora, ~ id_votacao))
  })
  
  return(votacoes)
}

#' @title Recupera informações das votações nominais do plenário em um intervalo de tempo (anos)
#' @description A partir de um ano de início e um ano de fim, recupera dados de 
#' votações nominais de plenário que aconteceram na Câmara dos Deputados
#' @param ano_inicial Ano inicial do período de votações
#' @param ano_final Ano final do período de votações
#' @return Votações da proposição em um intervalo de tempo (anos)
#' @examples
#' votacoes <- fetch_all_votacoes_por_intervalo_camara()
fetch_all_votacoes_por_intervalo_camara <- function(initial_date = "01/02/2019", 
                                                    end_date = format(Sys.Date(), "%d/%m/%Y")) {
  library(lubridate)
  library(tidyverse)
  source(here::here("crawler/votacoes/proposicoes_com_votacoes/fetcher_proposicoes_com_votacoes.R"))
  
  initial_date = dmy(initial_date)
  end_date = dmy(end_date)
  
  anos <- seq(initial_date %>% year(),
              end_date %>% year())
  
  proposicoes_votadas <-
    purrr::map_df(anos, ~ fetch_proposicoes_votadas_por_ano_camara(.x)) %>%
    mutate(data_votacao = dmy(data_votacao),
           ano_votacao = data_votacao %>% year()) %>%
    filter(data_votacao >= initial_date, data_votacao <= end_date) %>%  
    distinct(id, ano_votacao)
  
  votacoes <-
    purrr::map2_df(
      proposicoes_votadas$id,
      proposicoes_votadas$ano_votacao,
      ~ fetch_votacoes_por_ano_camara(.x, .y)
    ) %>%
    distinct(id_proposicao, obj_votacao, data, cod_sessao, hora, id_votacao)
  
  return(votacoes)
}
