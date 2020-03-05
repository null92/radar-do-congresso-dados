#' @title Classifica votações de acordo com seu status e apelido na tabela de votações de interesse do Radar
#' @description A partir da definição das votações de interesse classifica as votações 
#' capturadas para a legislatura atual
#' @param votacoes Dataframe com as votações capturadas 
#' (precisa pelo menos das colunas id_proposicao, obj_votacao, data, casa)
#' Data no formato "dd/mm/yyyy"
#' Hora no formato "mm:ss"
#' @return Dataframe contendo as votações nominais do período classificadas
process_votacoes_status_apelido <- function(votacoes) {
  library(tidyverse)
  library(here)
  source(here::here("crawler/votacoes/constants.R"))
  source(here::here("crawler/utils/utils.R"))
  
  votacoes_importantes <- read_csv(.URL_VOTACOES_IMPORTANTES) %>% 
    mutate(id_proposicao = as.character(ID)) %>%
    mutate(casa = padroniza_nome(Casa) %>% tolower()) %>% 
    select(nome_proposicao = `Proposição`,
           id_proposicao,
           casa,
           data = `Data da Votação`,
           objeto_votacao = ObjVotacao,
           apelido = `Descrição`) %>% 
    mutate(data = ifelse(casa == "camara", 
                             gsub( " -.*$", "", data),
                             data
                             ),
           data = as.Date(data, format = "%d/%m/%Y"))

  votacoes_alt <- votacoes %>% 
    mutate(obj_votacao_processed = padroniza_nome(obj_votacao)) %>% 
    left_join(votacoes_importantes %>% 
                mutate(objeto_votacao_processed = padroniza_nome(objeto_votacao)), 
              by = c("id_proposicao", "obj_votacao_processed" = "objeto_votacao_processed", "data", "casa")) %>% 
    mutate(status_importante = if_else(!is.na(apelido), 1, 0)) %>% 
    select(-c(nome_proposicao, obj_votacao_processed, objeto_votacao))
    
  return(votacoes_alt)
}

#' @title Lista de votações nominais em um determinado período
#' @description Retorna um dataframe com as votações de plenário para um determinado período
#' na Câmara e no Senado
#' @param initial_date Data de início de ocorrência das votações (formato "dd/MM/YYYY")
#' @param end_date Data de fim de ocorrência das votações (formato "dd/MM/YYYY")
#' @return Dataframe contendo as votações nominais do período.
process_proposicoes_votadas_e_votacoes <-
  function(initial_date = "01/02/2019",
           end_date = format(Sys.Date(), "%d/%m/%Y")) {
    library(tidyverse)
    library(here)
    source(here::here("crawler/votacoes/fetcher_votacoes_camara.R"))
    source(here::here("crawler/votacoes/fetcher_votacoes_senado.R"))
    source(here::here("crawler/proposicoes/fetcher_proposicoes.R"))
    
    votacoes_camara <-
      fetch_all_votacoes_por_intervalo_camara(initial_date, end_date)
    votacoes_camara_alt <- votacoes_camara %>%
      mutate(
        data_hora = paste0(data, " ", hora),
        votacao_secreta = 0,
        casa = "camara"
      ) %>%
      process_votacoes_status_apelido() %>% 
      select(id_proposicao, id_votacao, casa, obj_votacao, data_hora, votacao_secreta, 
             apelido, status_importante)
    
    votacoes_senado <-
      fetcher_votacoes_por_intervalo_senado(initial_date, end_date)
    votacoes_senado_alt <- votacoes_senado %>%
      mutate(data_hora = as.character(datetime),
             casa = "senado") %>%
      rename(obj_votacao = objeto_votacao,
             data = datetime) %>% 
      process_votacoes_status_apelido() %>% 
      select(id_proposicao, id_votacao, casa, obj_votacao, data_hora,
             votacao_secreta, apelido, status_importante, url_votacao = link_votacao)
    
    votacoes <- bind_rows(votacoes_camara_alt, votacoes_senado_alt)
    
    ids_proposicoes_camara <- votacoes_camara_alt %>%
      distinct(id_proposicao)
    
    proposicoes_camara <-
      map_df(ids_proposicoes_camara$id_proposicao,
              ~ fetcher_proposicao_por_id_camara(.x)) %>% 
      mutate(id_proposicao = as.character(id_proposicao))
    
    ids_proposicoes_senado <- votacoes_senado_alt %>%
      distinct(id_proposicao)
    
    proposicoes_senado <-
      map_df(ids_proposicoes_senado$id_proposicao,
              ~ fetcher_proposicao_por_id_senado(.x)) %>% 
      mutate(id_proposicao = as.character(id_proposicao),
             ano = as.numeric(ano))
    
    proposicoes_votadas <-
      bind_rows(proposicoes_camara, proposicoes_senado)
    
    return(list(proposicoes_votadas, votacoes))
  }