#' @title Captura votos em uma Eleição usando API do Datapedia (https://eleicoes.datapedia.info/)
#' @description Utiliza API do Datapedia para capturar votos recebidos por candidatos nas eleições
#' @param uf UF para recuperação dos candidatos
#' @param codigo_cargo Código do cargo no TSE (5 para Senador e 6 para Deputado Federal)
#' @param ano Ano de ocorrência da eleição
#' @return Dataframe contendo informações dos candidatos e os votos recebidos na eleição
#' @examples
#' fetch_votos_eleicao_por_uf()
#' 
fetch_votos_eleicao_por_uf <- function(uf, codigo_cargo, ano) {
  library(tidyverse)
  
  message(paste0("Baixando dados para UF: ", uf, " Cargo: ", codigo_cargo, " Ano: ", ano))
  url <- paste0("https://eleicoes.datapedia.info/api/candidates/post/", codigo_cargo, "/", ano, "/", uf, "/0")
  
  info_candidatos <- (RCurl::getURL(url) %>% jsonlite::fromJSON())$rows %>% 
    unnest(candidate_status) %>%
    mutate(electoral_id = as.character(electoral_id),
           codigo_cargo = codigo_cargo,
           ano = ano) %>% 
    select(id_tse = electoral_id, ano, codigo_cargo, cpf, nome = name, uf = state, resultado_eleicao = result, 
           total_votos = sum_votes)
  
  return(info_candidatos)
}

#' @title Processa dados dos votos recebidos para candidatos (de todas as UF's) de determinados cargos em determinado ano
#' @description Utiliza API do Datapedia para capturar votos recebidos por candidatos (de todas as UF's) em uma eleição específica
#' @param lista_cargos Lista com os códigos dos cargos dos candidatos de interesse (Exemplo: c(5, 6)). 
#' 5 para Senadores e 6 para deputados
#' @return Dataframe contendo informações dos candidatos e os votos recebidos na eleição
#' @examples
#' fetch_votos_eleicao(lista_cargos = c(5, 6), ano = 2018)
#' 
fetch_votos_eleicao <- function(lista_cargos = c(5, 6), ano = 2018) {
  library(tidyverse)
  
  ufs <- c("AC", "AL", "AM", "AP", "BA", "CE", "DF", "ES", "GO", "MA", "MG", 
           "MS", "MT", "PA", "PB", "PE", "PI", "PR", "RJ", "RN", "RO", "RR", "RS", 
           "SC", "SE", "SP", "TO")

  ufs_cargos <- expand.grid(uf_req = ufs, codigo_cargo_req = lista_cargos)
  
  candidatos <- ufs_cargos %>%
    mutate(dados = map2(
      uf_req,
      codigo_cargo_req,
      fetch_votos_eleicao_por_uf,
      ano
    )) %>%
    unnest(dados) %>% 
    select(-c(uf_req, codigo_cargo_req))
  
  return(candidatos)
}
