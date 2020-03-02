#' @title Baixa dados da assiduidade dos deputados para uma lista de anos
#' @description Baixa os dados da assiduidade da legislatura atual para uma lista de anos
#' @param anos Lista de anos
#' @return Dataframe contendo informações da assiduidade
fetch_assiduidade_camara <- function(anos = c(2019, 2020)) {
  library(tidyverse)
  
  assiduidade <- map_df(anos, ~ fetch_assiduidade_camara_por_ano(.x))
  
  assiduidade <- assiduidade %>% 
    mutate(total = as.numeric(total), 
           percentual = as.numeric(percentual)) %>% 
    select(id_parlamentar, ano, metrica, total, percentual)
  
  return(assiduidade)
}

#' @title Baixa dados da assiduidade dos deputados para um ano
#' @description Baixa os dados da assiduidade da legislatura atual para um ano
#' @param ano Ano de interesse
#' @param parlamentares_filepath Caminho para o csv dos parlamentares
#' @return Dataframe contendo informações da assiduidade
fetch_assiduidade_camara_por_ano <- function(ano = 2019, parlamentares_filepath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  
  deputados <- read_csv(parlamentares_filepath) %>% 
    filter(casa == "camara") %>%
    pull(id)
  
  assiduidade <- map_df(deputados, ~ fetch_assiduidade_camara_por_ano_e_parlamentar(ano, .x))
  
  return(assiduidade)
}

#' @title Baixa dados da assiduidade de um deputado para um ano
#' @description Baixa os dados da assiduidade da legislatura atual para um ano e um deputado
#' @param ano Ano de interesse
#' @param id_parlamentar ID do parlamentar
#' @return Dataframe contendo informações da assiduidade
fetch_assiduidade_camara_por_ano_e_parlamentar <- function(ano, id_parlamentar) {
  library(tidyverse)
  library(rvest)
  
  print(paste0("Baixando assiduidade do parlamentar ", id_parlamentar, " no ano ", ano, "..."))
  
  assiduidade <- tryCatch({
    url <- paste0("https://www.camara.leg.br/deputados/", id_parlamentar, "/presenca-plenario/", ano)
    
    html <- xml2::read_html(url)
    
    table <- html_nodes(html, "table")[[2]]
    
    trs <- table %>% html_nodes("tr:not(.info-data)")
    
    df <- map_df(trs, function(.x) {
      text <- .x %>% 
        html_nodes('td') %>% 
        html_text()
      
      if (length(text) != 3) {
        return(tribble(~ metrica, ~ total, ~ percentual))
      }
      
      data <- tribble(
        ~ metrica, ~ total, ~ percentual,
        gsub(pattern = "\\n|\\t|\\*", replacement = "", text[1]),
        gsub(pattern = "\\n|\\t| ", replacement = "", text[2]),
        gsub(pattern = "\\n|\\t| |%", replacement = "", text[3]) %>% 
          gsub(",", ".", .)
      )
      
      return(data)
    })
  }, error = function(e) {
    return(tribble(~ metrica, ~ total, ~ percentual))
  })
  
  assiduidade <- assiduidade %>% 
    mutate(ano = ano,
           id_parlamentar = id_parlamentar)
  
  return(assiduidade)
}
