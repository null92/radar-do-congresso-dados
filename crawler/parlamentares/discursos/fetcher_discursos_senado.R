#' @title Recupera discursos de um senador disponibilzados pela API do Senado
#' @description A partir do id do senador recupera seus discursos no Senado em um período de tempo
#' @param id_senador Id do senador 
#' @param data_inicial Data Inicial para captura dos discursos (Formato yyyymmdd).
#' @param data_final Data final para captura dos discursos (Formato yyyymmdd).
#' @return Dataframe contendo discursos do senador em um período de tempo
#' @examples
#' fetch_discursos_senador(4981)
#' 
fetch_discursos_senador <- function(id_senador, data_inicial = "20190131", data_final = gsub(x = Sys.Date(), "-", "")) {
  library(tidyverse)
  
  url <- paste0("https://legis.senado.leg.br/dadosabertos/senador/", id_senador, 
                "/discursos?dataInicio=", data_inicial, "&dataFim=", data_final)
  
  print(paste0("Baixando discursos do senador ", id_senador, " entre ", data_inicial, " e ", data_final))
  
  empty_dataframe <- tibble(id_discurso = character(), id_parlamentar = character(), casa = character(), tipo = character(),
                            data = character(), local = character(), resumo = character(), link = character())
  
  tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    if (xml2::xml_find_all(xml, ".//Pronunciamento") %>% rlang::is_empty()) {
      return(empty_dataframe)
    }
    discursos <- xml2::xml_find_all(xml, ".//Pronunciamento") %>%
      map_df(function(x) {
        list(
          id_discurso = xml2::xml_find_first(x, ".//CodigoPronunciamento") %>%
            xml2::xml_text(),
          tipo = xml2::xml_find_first(x, ".//DescricaoTipoPronunciamento") %>%
            xml2::xml_text(),
          data = xml2::xml_find_first(x, ".//DataPronunciamento") %>%
            xml2::xml_text(),
          local = xml2::xml_find_first(x, ".//NomeCasaPronunciamento") %>%
            xml2::xml_text(),
          resumo = xml2::xml_find_first(x, ".//TextoResumo") %>%
            xml2::xml_text(),
          link = xml2::xml_find_first(x, ".//UrlTexto") %>%
            xml2::xml_text()
        )
      }) %>%
      mutate(casa = "senado") %>%
      mutate(id_parlamentar = id_senador %>% as.character()) %>%
      select(id_discurso, id_parlamentar, casa, tipo, data, local, resumo, link)
    
    return(discursos)
    
  }, error = function(e) {
    print(e)
    data <- empty_dataframe
    return(data)
  })
}

#' @title Recupera discursos dos senadores da legislatura atual
#' @description Captura os discursos de todos os senadores da legislatura atual
#' @return Dataframe contendo discursos dos senadores
#' @examples
#' fetch_discursos_todos_senadores()
fetch_discursos_todos_senadores <- function() {
  library(tidyverse)
  library(here)
  
  senadores <- read_csv(here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == "senado")
  
  discursos_senado <- purrr::map_df(senadores$id, ~ fetch_discursos_senador(.x))
  
  return(discursos_senado)
}
