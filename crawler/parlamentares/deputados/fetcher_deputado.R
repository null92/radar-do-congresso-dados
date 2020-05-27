#' @title Extrai informações de um partido a partir de uma URL
#' @description Recebe uma URL da câmara que possui o formato '/partidos/:num e extrai id e nome
#' @param URL no formato "https://dadosabertos.camara.leg.br/api/v2/partidos/:num"
#' @return Dataframe contendo informações de id e nome dos partidos
#' @examples
#' extract_partido_informations("https://dadosabertos.camara.leg.br/api/v2/partidos/36835")
extract_partido_informations <- function(url) {
  partido <- tryCatch({
    data <-  RCurl::getURL(url) %>% 
      jsonlite::fromJSON() %>% 
      unlist() %>% t() %>% 
      as.data.frame() %>% 
      select(num_partido = dados.id, 
             partido = dados.nome)
  }, error = function(e) {
    data <- tribble(
      ~ num_partido, ~ partido)
    return(data)
  })
  
  return (partido)
}

#' @title Importa dados de todos os deputados de uma legislatura específica utilizando backoff exponencial
#' @description Importa os dados de todos os deputados federais de uma legislatura específica 
#' utilizando backoff exponencial com 10 tentativas 
#' @return Dataframe contendo informações dos deputados: id, nome civil e cpf
#' @examples
#' deputados <- fetch_deputados_with_backoff(56)
fetch_deputados_with_backoff <- function(legislatura = 56) {
  library(tidyverse)
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados?idLegislatura=", legislatura)
  
  ids_deputados <- 
    (RCurl::getURL(url) %>%
       jsonlite::fromJSON())$dados %>% 
    select(id) %>% distinct() %>% 
   rowid_to_column(var = 'indice')
  
  info_pessoais <- 
    purrr::map_df(ids_deputados$id, ~ fetch_deputado_with_backoff(.x))
    
  return(info_pessoais %>% 
           unique() %>% 
           mutate_if(is.factor, as.character) %>% 
           mutate(id = as.integer(id),
                  legislatura = legislatura))
}

#' @title Baixa dados dos deputados utilizando backoff exponencial
#' @description Baixa nome civil dos deputados pelo id do parlamentar na Câmara utilizando backoff exponencial
#' com N tentativas (10 por padrão)
#' @param id_votacao id do deputado
#' @return Dataframe informações de id e nome civil.
#' @examples
#' deputado <- fetch_deputado_with_backoff(73874)
fetch_deputado_with_backoff <- function(id_deputado, max_attempts = 10) {
  print(paste0("Baixando informações do deputado de id ", id_deputado, "..."))
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/deputados/", id_deputado)
  
  
  for (attempt_i in seq_len(max_attempts)) {
  
    deputado <- tryCatch({
      data <-  RCurl::getURL(url) %>% 
        jsonlite::fromJSON() %>% 
        unlist() %>% t() %>% 
        as.data.frame() 
      
      atributos_a_serem_utilizados <- c("dados.ultimoStatus.situacao",
                                        "dados.escolaridade",
                                        "dados.ultimoStatus.gabinete.email",
                                        "dados.ultimoStatus.gabinete.predio",
                                        "dados.ultimoStatus.gabinete.andar",
                                       "dados.ultimoStatus.gabinete.sala",
                                       "dados.ultimoStatus.gabinete.telefone",
                                       "dados.ufNascimento")
      
      data <- check_field_in_dataframe(atributos_a_serem_utilizados, data)
    
      
      data <- data %>% 
        dplyr::bind_cols(
          extract_partido_informations(data$dados.ultimoStatus.uriPartido)) %>% 
        mutate(casa = "camara",
               naturalidade = paste0(dados.municipioNascimento, " - ", dados.ufNascimento)) %>% 
        select(id = dados.id, 
               casa,
               cpf = dados.cpf,
               nome_civil = dados.nomeCivil,
               nome_eleitoral = dados.ultimoStatus.nomeEleitoral,
               uf = dados.ultimoStatus.siglaUf,
               num_partido,
               sg_partido = dados.ultimoStatus.siglaPartido,
               partido,
               situacao = dados.ultimoStatus.situacao,
               condicao_eleitoral = dados.ultimoStatus.condicaoEleitoral,
               genero = dados.sexo,
               escolaridade = dados.escolaridade,
               email = dados.ultimoStatus.gabinete.email,
               data_nascimento = dados.dataNascimento, ## yyyy-mm-dd
               escolaridade = dados.escolaridade,
               anexo = dados.ultimoStatus.gabinete.predio,
               andar = dados.ultimoStatus.gabinete.andar,
               sala = dados.ultimoStatus.gabinete.sala,
               naturalidade,
               telefone = dados.ultimoStatus.gabinete.telefone
               )
      
      return(data)
    }, error = function(e) {
      print(e)
      data <- tribble(~ id, ~ casa, ~ cpf, ~ nome_civil, ~ nome_eleitoral, ~ uf, ~ num_partido, 
      ~ sg_partido, ~ partido, ~ situacao, ~ condicao_eleitoral, ~ genero, ~ escolaridade, ~ email,
      ~ data_nascimento, ~ anexo, ~ andar, ~ sala, ~ naturalidade, ~ telefone)
      return(data)
    })
    
    if (nrow(deputado) == 0) {
      backoff <- runif(n = 1, min = 0, max = 2 ^ attempt_i - 1)
      message("Backing off for ", backoff, " seconds.")
      Sys.sleep(backoff)
    } else {
      break
    }
  }
  
  deputado <- deputado %>% 
    mutate(endereco = 
             if_else(!is.na(andar) & !is.na(sala) & !is.na(anexo), 
                     paste0("Anexo ", anexo, ", ", andar, "º, Sala ", sala),
                     '-')) %>% 
    select(-c(andar, sala, anexo))
  
  return(deputado)
}

#' @title Processa atributo de dataframe, criando-o caso não exista
#' @description Recebe uma lista de atributos e um dataframe e cria caso não exista
#' @param field Campo a ser checado
#' @param df Dataframe
#' @return Dataframe contendo o atributo, caso não exista
check_field_in_dataframe <- function(fields, df) {
  for (field in fields) {
    if (!field %in% names(df)) {
      df[field] = NA
    }
  }
  
  return(df)
}
