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
    source(here::here("crawler/votacoes/constants.R"))
    source(here::here("crawler/utils/utils.R"))
    
    votacoes_importantes <- read_csv(.URL_VOTACOES_IMPORTANTES_COPIA) %>% 
      mutate(id_proposicao = as.character(ID)) %>% 
      select(nome_proposicao = `Proposição`,
             id_proposicao,
             casa = Casa,
             objeto_votacao = `Texto do Objeto da Votação Importante`) %>% 
      filter(!str_detect(objeto_votacao, "sem votações"))
    
    votacoes_camara <-
      fetch_all_votacoes_por_intervalo_camara(initial_date, end_date)
    votacoes_camara_alt <- votacoes_camara %>%
      mutate(
        data_hora = paste0(data, " ", hora),
        votacao_secreta = 0,
        casa = "camara"
      ) %>%
      mutate(obj_votacao_processed = padroniza_nome(obj_votacao)) %>% 
      left_join(votacoes_importantes %>% 
                  mutate(objeto_votacao_processed = padroniza_nome(objeto_votacao)), 
                by = c("casa", "id_proposicao", "obj_votacao_processed" = "objeto_votacao_processed")) %>% 
      mutate(status_importante = !is.na(nome_proposicao)) %>% 
      select(id_proposicao, id_votacao, casa, obj_votacao, data_hora, votacao_secreta, status_importante)
    
    votacoes_senado <-
      fetcher_votacoes_por_intervalo_senado(initial_date, end_date)
    votacoes_senado_alt <- votacoes_senado %>%
      mutate(data_hora = as.character(datetime),
             casa = "senado") %>%
      select(id_proposicao, id_votacao, casa, obj_votacao = objeto_votacao, data_hora,
             votacao_secreta, url_votacao = link_votacao) %>% 
      mutate(obj_votacao_processed = padroniza_nome(obj_votacao)) %>% 
      left_join(votacoes_importantes %>% 
                  mutate(objeto_votacao_processed = padroniza_nome(objeto_votacao)), 
                by = c("casa", "id_proposicao", "obj_votacao_processed" = "objeto_votacao_processed")) %>% 
      mutate(status_importante = !is.na(nome_proposicao))
    
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