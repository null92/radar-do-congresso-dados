#' @title Recupera discursos de um deputado disponibilzados pela API da Câmara
#' @description A partir do id do deputado recupera seus discursos no Câmara na legislatura atuaç
#' @param id_deputado Id do deputado 
#' @return Dataframe contendo discursos do deputado na legislatura atual
#' @examples
#' fetch_discursos_deputado(74693)
#' 
fetch_discursos_deputado <- function(id_deputado) {
  library(tidyverse)
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados/", 
                id_deputado,
                "/discursos?idLegislatura=56&itens=1000")
  print(paste0("Baixando discursos do deputado ", id_deputado))
  
  links <- tryCatch({
    (RCurl::getURL(url) %>% jsonlite::fromJSON())$links
  }, error = function(e) {
    print(e)
    return(tibble())
  })
  
  if (links %>% filter(rel == "last") %>% nrow() == 0) {
    return()
  }
    
  last_page <- links %>% 
    filter(rel == "last") %>% 
    pull(href) %>% 
    str_match("pagina=(.*?)&") %>% 
    tibble::as_tibble(.name_repair = c("universal")) %>% 
    pull(`...2`)
  
  discursos <- tibble(page = 1:as.numeric(last_page)) %>%
    mutate(data = map(
      page,
      fetch_discursos_deputado_by_page,
      url,
      last_page,
      id_deputado,
      10
    )) %>% 
    unnest(data) %>% 
    select(-page)
  
  return(discursos)
}

#' @title Recupera informações dos discursos de um deputado para cada página da API da Câmara
#' @description Captura discursos de uma página da API da Câmara dos deputados
#' @param page Página a ser requisitada
#' @param url Url da requisição
#' @param last_page Última página a ser requisitada
#' @param id_deputado ID do deputado
#' @param max_tentativas Número máximo de tentativas
#' @return Dataframe com informações dos discursos
#' 
fetch_discursos_deputado_by_page <- function(page = 1,  url, last_page, id_deputado, max_tentativas = 10) {
  library(tidyverse)
  
  url_paginada <- paste0(url, '&pagina=', page)
  
  print(paste0("Baixando discurso do deputado ", id_deputado, " para a página ", page, "/", last_page))
  
  empty_dataframe <- tibble(id_parlamentar = character(), casa = character(), tipo = character(),
                            data = character(), local = character(), resumo = character(), link = character())
  
  for (tentativa in seq_len(max_tentativas)) {
    print(paste0("Tentativa ", tentativa, "/", max_tentativas))
    
    discursos <- tryCatch(
      {
        discursos_raw <- tryCatch({
          (RCurl::getURL(url_paginada) %>% 
             jsonlite::fromJSON())$dados %>% 
            as_tibble()
        }, error = function(e) {
          print(e)
          return(tibble())
        })
        
        if (nrow(discursos_raw) == 0) {
          return(empty_dataframe)
        }
        
        discursos <- discursos_raw %>% 
          mutate(id_parlamentar = as.character(id_deputado),
                 casa = "camara",
                 local = "",
                 data_inicio = lubridate::ymd_hm(dataHoraInicio) %>% lubridate::date() %>% as.character()) %>% 
          select(id_parlamentar, casa, tipo = tipoDiscurso, data = data_inicio,
                 local, resumo = sumario, link = urlTexto)
        
        return(discursos)
      }, error = function(e) {
        print(e)
        return(empty_dataframe)
      }
    )
    
    if (nrow(discursos_raw) == 0) {
      backoff <- runif(n = 1, min = 0, max = 2 ^ tentativa - 1)
      message("Backing off for ", backoff, " seconds.")
      Sys.sleep(backoff)
    } else {
      break
    }
  }
  return(discursos)
}

#' @title Recupera discursos dos deputados da legislatura atual
#' @description Captura os discursos de todos os deputados da legislatura atual
#' @return Dataframe contendo discursos dos deputados
#' @examples
#' fetch_discursos_todos_deputados()
fetch_discursos_todos_deputados <- function() {
  library(tidyverse)
  library(here)
  
  deputados <- read_csv(here::here("crawler/raw_data/parlamentares.csv")) %>% 
    filter(casa == "camara")
  
  discursos_camara <- purrr::map_df(deputados$id, ~ fetch_discursos_deputado(.x)) %>% 
    distinct() %>% 
    tibble::rowid_to_column(var = "id_discurso")
  
  return(discursos_camara)
}
