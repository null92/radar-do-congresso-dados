#' @title Padroniza palavra para comparação
#' @description Recebe uma palavra, retira acentos e deixa em uppercase.
#' @param string Palavra a ser padronizada
#' @return Palavra padronizada
padroniza_string <- function(string) {
  string = iconv(toupper(string), to = "ASCII//TRANSLIT")
  return(string)
}

#' @title Padroniza siglas de partidos
#' @description Recebe uma sigla de partido como input e retorna seu valor padronizado
#' @param sigla Sigla do partido
#' @return Dataframe com sigla do partido padronizada
padroniza_sigla <- function(sigla) {
  sigla = toupper(sigla)
  
  sigla_padronizada <- case_when(
    str_detect(tolower(sigla), "ptdob") ~ "AVANTE",
    str_detect(tolower(sigla), "pcdob") ~ "PCdoB",
    str_detect(tolower(sigla), "ptn") ~ "PODEMOS",
    str_detect(tolower(sigla), "pps") ~ "CIDADANIA",
    str_detect(tolower(sigla), "pmdb") ~ "MDB",
    str_detect(tolower(sigla), "pfl") ~ "DEM",
    str_detect(tolower(sigla), "patri") ~ "PATRIOTA",
    str_detect(tolower(sigla), "pc do b") ~ "PCdoB",
    str_detect(tolower(sigla), "pt do b") ~ "PTdoB",
    tolower(sigla) == "pr" ~ "PL",
    str_detect(sigla, "SOLID.*") ~ "SD",
    str_detect(sigla, "REPUBLICANOS") ~ "Rep",
    str_detect(sigla, "PODE.*") ~ "PODEMOS",
    str_detect(sigla, "GOV.") ~ "GOVERNO",
    str_detect(sigla, "PHS.*") ~ "PHS",
    TRUE ~ sigla
  ) %>%
    stringr::str_replace("REPR.", "") %>% 
    stringr::str_replace_all("[[:punct:]]", "") %>% 
    trimws(which = c("both"))
  
  return(sigla_padronizada)
}

#' @title Mapeia sigla padronizada para sigla usada na tabela de partidos (crawler/raw_data/partidos.csv)
#' @description Recebe uma string com a sigla padronizada do partido e retorna a sigla correspondente na
#' tabela de partidos
#' @param sigla Sigla padronizada do partido (string)
#' @return Sigla correspondente em crawler/raw_data/partidos.csv
map_sigla_padronizada_para_sigla <- function(sigla) {
  library(tidyverse)
  
  sigla_clean <- padroniza_string(sigla)
  
  sigla_alt <- case_when(
    str_detect(sigla_clean, "PODEMOS") ~ "PODE",
    str_detect(sigla_clean, "REPUBLICANOS") ~ "Rep",
    str_detect(sigla_clean, "BLOCO PP MDB PTB") ~ "BLOCO PP, MDB, PTB",
    str_detect(sigla_clean, "BLOCO PARLAMENTAR PSDBPSL") ~ "BLOCO PARLAMENTAR PSDB/PSL",
    TRUE ~ sigla_clean
  )
  
  return(sigla_alt)
}

#' @title Mapeia sigla de partido para id
#' @description Recebe uma string com a sigla do partido e retorna qual o ID deste partido
#' @param sigla Sigla do partido (string)
#' @return Id do partido
map_sigla_id <- function(sigla_partido) {
  library(tidyverse)
  library(here)
  
  partidos <- suppressWarnings(suppressMessages(read_csv(here::here("crawler/raw_data/partidos.csv"))))
  
  sigla_padronizada <- padroniza_sigla(sigla_partido) %>% 
    padroniza_string()
  
  id_partido <- partidos %>% 
    filter(padroniza_string(sigla) == map_sigla_padronizada_para_sigla(sigla_padronizada)) %>%
    pull(id)
  
  if (length(id_partido) == 0) {
    return(partidos %>% filter(sigla == "SPART") %>% pull(id))
  } else {
    return(id_partido)
  }
}
