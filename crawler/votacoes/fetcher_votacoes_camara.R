#' @title Recupera todas votações por ano
fetch_votacoes_por_ano_camara <- function(ano = seq(2019, format(Sys.Date(), "%Y"))){
  library(tidyverse)
  source(here::here("crawler/votacoes/utils_votacoes.R"))

  url_orientacoes <- paste0("http://dadosabertos.camara.leg.br/arquivos/votacoesOrientacoes/csv/votacoesOrientacoes-",ano,".csv")
  orientacoes <- read_delim(url_orientacoes, delim = ";") %>%
                  filter(siglaBancada == "Governo" | siglaBancada == "GOV.") %>%
                  mutate(id_votacao = idVotacao, orientacao = get_val_voto(orientacao)) %>%
                  select(id_votacao, orientacao)

  url_votacoes <- paste0("http://dadosabertos.camara.leg.br/arquivos/votacoes/csv/votacoes-",ano,".csv")
  votacoes <- read_delim(url_votacoes, delim = ";") %>%
    mutate(
      id_proposicao = as.character(sapply(strsplit(id,"-"), `[`, 1)),
      id_votacao = id,
      obj_votacao = ifelse(nchar(ultimaApresentacaoProposicao_descricao) > 150, paste0(substring(ultimaApresentacaoProposicao_descricao, 1, 147), "..."), ultimaApresentacaoProposicao_descricao),
      data = as.Date(data, format = "%Y-%m-%d"),
      data_hora = dataHoraRegistro,
      apelido = "indisponivel",
      status_importante = 0
    ) %>%
    select(
      id_proposicao,
      id_votacao,
      obj_votacao,
      data,
      data_hora,
      apelido,
      status_importante
    ) 

  votacoes_orientadas <- merge(votacoes, orientacoes, by="id_votacao")

  return (votacoes_orientadas);
}

#' @title Recupera informações das votações nominais do plenário em um intervalo de tempo (anos)
#' @description A partir de um ano de início e um ano de fim, recupera dados de 
#' votações nominais de plenário que aconteceram na Câmara dos Deputados
#' @param ano_inicial Ano inicial do período de votações
#' @param ano_final Ano final do período de votações
#' @return Votações da proposição em um intervalo de tempo (anos)
#' @examples
#' votacoes <- fetch_all_votacoes_por_intervalo_camara()
fetch_all_votacoes_por_intervalo_camara <- function(initial_date = "01/02/2019", end_date = format(Sys.Date(), "%d/%m/%Y")) {
  library(lubridate)
  library(tidyverse)
  
  initial_date = dmy(initial_date)
  end_date = dmy(end_date)
  
  anos <- seq(initial_date %>% year(),
              end_date %>% year())
  
  todas_votacoes <-
    purrr::map_df(anos, ~ fetch_votacoes_por_ano_camara(.x))
  
  votacoes <- todas_votacoes %>%
    select(id_proposicao, id_votacao, obj_votacao, data, data_hora, apelido, status_importante,orientacao)

  return(votacoes)
}
