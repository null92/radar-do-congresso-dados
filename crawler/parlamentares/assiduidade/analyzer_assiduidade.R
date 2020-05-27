#' @title Baixa dados da assiduidade dos deputados para uma lista de anos
#' @description Baixa os dados da assiduidade da legislatura atual para uma lista de anos
#' @param anos Lista de anos
#' @return Dataframe contendo informações da assiduidade
process_assiduidade <- function(anos = seq(2019, format(Sys.Date(), "%Y"))) {
  library(tidyverse)
  library(jsonlite)
  library(fuzzyjoin)
  
  source(here::here("crawler/parlamentares/assiduidade/fetcher_assiduidade_camara.R"))
  assiduidade_regex_df <- fromJSON(here::here("crawler/parlamentares/assiduidade/constants.json"))$assiduidade
  
  assiduidade <- fetch_assiduidade_camara(anos)
  
  assiduidade_alt <- assiduidade %>%
    mutate(metrica = tolower(metrica)) %>% 
    filter(str_detect(metrica, "total de dias")) %>% 
    inner_join(assiduidade_regex_df, by = c("metrica" = "regex_assiduidade")) %>% 
    select(-metrica) %>% 
    spread(texto_assiduidade, total)
  
  return(assiduidade_alt)
}