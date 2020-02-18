#' @title Baixa dados de proposições apresentadas na Câmara
#' @description Baixa as proposições que foram aprensentadas na 56ª legislatura
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_camara(anos = c(2019, 2020))
fetcher_proposicoes_camara <- function(anos = seq(2019, 2020)) {
  library(tidyverse)
  
  proposicoes <- purrr::map_df(anos, ~ fetcher_proposicoes_por_ano_camara(.x))
  
  return(proposicoes)
}

#' @title Baixa dados de proposições apresentadas na Câmara em um ano
#' @description Baixa as proposições que foram aprensentadas em um ano
#' @param ano Ano de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_camara(2019)
fetcher_proposicoes_por_ano_camara <- function(ano) {
  library(tidyverse)
  
  url_parlamentares_proposicoes <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-", ano, ".csv")
  
  parlamentares_proposicoes <- read_delim(url_parlamentares_proposicoes, delim = ";") %>% 
    filter(tipoAutor == "Deputado", !is.na(idDeputadoAutor))
  
  parlamentares_proposicoes <- parlamentares_proposicoes %>% 
    select(id_proposicao = idProposicao,
           id_parlamentar = idDeputadoAutor) %>% 
    distinct()
  
  url_proposicoes <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-", ano, ".csv")
  
  proposicoes <- read_delim(url_proposicoes, delim = ";") %>% 
    filter(id %in% parlamentares_proposicoes$id_proposicao, ano == ano)
  
  proposicoes_alt <- proposicoes %>% 
    mutate(nome = paste0(siglaTipo, " ", numero, "/", ano),
           casa = "camara",
           ano = ano) %>% 
    select(id_proposicao = id,
           casa,
           nome,
           ano,
           ementa,
           url = uri) %>% 
    left_join(parlamentares_proposicoes,
              by = "id_proposicao") %>%
    distinct()
  
  return(proposicoes_alt)
}
