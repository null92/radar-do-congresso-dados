#' @title Lista de proposições votadas em um determinado período
#' @description Lista as proposições votadas em plenário para um determinado período
#' @param initial_date Data de início de ocorrência das votações (formato "dd/MM/YYYY")
#' @param end_date Data de fim de ocorrência das votações (formato "dd/MM/YYYY")
#' @return Dataframe contendo id das proposições que tiveram votações nominais no período.
#' @examples
#' proposicoes_votadas_camara <- fetch_proposicoes_votadas_por_intervalo_camara()
fetch_proposicoes_votadas_por_intervalo_camara <-
  function(initial_date = "01/02/2019",
           end_date = format(Sys.Date(), "%d/%m/%Y")) {
    library(tidyverse)
    library(lubridate)
    source(here::here("crawler/proposicoes/fetcher_proposicoes.R"))
    
    initial_date = dmy(initial_date)
    end_date = dmy(end_date)
    
    anos <- seq(initial_date %>% year(),
                end_date %>% year())
    
    id_proposicoes_votadas <-
      map_df(anos, ~ fetch_proposicoes_votadas_por_ano_camara(.x)) %>%
      mutate(data_votacao = dmy(data_votacao)) %>%
      filter(data_votacao >= initial_date, data_votacao <= end_date) %>%
      distinct(id)
    
    proposicoes <-
      map_df(id_proposicoes_votadas$id,
             ~ fetcher_proposicao_por_id_camara(.x))
    
    return(proposicoes)
  }

#' @title Lista de proposições votadas em um determinado ano
#' @description Lista as proposições votadas em plenário para um determinado ano
#' @param ano Ano de ocorrência das votações
#' @return Dataframe contendo id da proposição, nome e data da votação
#' @examples
#' proposicoes_votadas_em_2019 <- fetch_proposicoes_votadas_por_ano_camara(2019)
fetch_proposicoes_votadas_por_ano_camara <- function(ano = 2019) {
  library(tidyverse)
  library(RCurl)
  library(xml2)
  library(jsonlite)
  
  url_votacoes <-
    "https://www.camara.leg.br/SitCamaraWS/Proposicoes.asmx/ListarProposicoesVotadasEmPlenario?ano=%s&tipo="
  
  url <- url_votacoes %>%
    sprintf(ano)
  
  proposicoes <- tryCatch({
    xml <- getURL(url) %>% read_xml()
    
    data <- xml_find_all(xml, ".//proposicao") %>%
      map_df(function(x) {
        list(
          id = xml_find_first(x, ".//codProposicao") %>%
            xml_text(),
          nome_proposicao = xml_find_first(x, ".//nomeProposicao") %>%
            xml_text(),
          data_votacao = xml_find_first(x, ".//dataVotacao") %>%
            xml_text()
        )
      }) %>%
      select(id, nome_proposicao, data_votacao)
    
  }, error = function(e) {
    message(e)
    data <- tribble( ~ id, ~ nome_proposicao, ~ data_votacao)
    return(data)
  })
  
  return(proposicoes)
}

#' @title Lista de proposições votadas em um determinado período
#' @description Lista as proposições votadas em plenário para um determinado período
#' @param initial_date Data de início de ocorrência das votações (formato "dd/MM/YYYY")
#' @param end_date Data de fim de ocorrência das votações (formato "dd/MM/YYYY")
#' @return Dataframe contendo id das proposições que tiveram votações nominais no período.
#' @examples
#' proposicoes_votadas_senado <- fetch_proposicoes_votadas_por_intervalo_senado()
fetch_proposicoes_votadas_por_intervalo_senado <-
  function(initial_date = "01/02/2019",
           end_date = format(Sys.Date(), "%d/%m/%Y")) {
    library(tidyverse)
    source(here::here("crawler/votacoes/fetcher_votacoes_senado.R"))
    source(here::here("crawler/proposicoes/fetcher_proposicoes.R"))
    
    id_proposicoes_votadas <-
      fetcher_votacoes_por_intervalo_senado(initial_date, end_date) %>%
      distinct(id_proposicao)
    
    proposicoes <-
      map_df(id_proposicoes_votadas$id_proposicao,
             ~ fetcher_proposicao_por_id_senado(.x))
    
    return(proposicoes)
  }