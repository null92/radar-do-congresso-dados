#' @title Processa dados de deputados
#' @description Processa informações sobre os deputados da legislatura 56
#' @return Dataframe contendo informações sobre os deputados
#' @examples
#' #' processa_dados_deputados()
processa_dados_deputados <- function() {
  library(tidyverse)
  library(here)
  
  # Lista das legislaturas de interesse
  legislaturas_list <- c(56)
  
  source(here::here("crawler/parlamentares/deputados/fetcher_deputado.R"))
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  deputados <- purrr::map_df(legislaturas_list, ~ fetch_deputados_with_backoff(.x))
  
  deputados_alt <- deputados %>% 
    group_by(id) %>% 
    rename("ultima_legislatura" = "legislatura") %>% 
    mutate(ultima_legislatura = max(ultima_legislatura)) %>% 
    distinct() %>% 
    mutate(sg_partido = padroniza_sigla(sg_partido)) %>% 
    mutate(em_exercicio = dplyr::if_else(situacao == 'Exercício', 1, 0)) %>%
    mutate(endereco =  if_else(!is.na(anexo) & !is.na(andar) & !is.na(sala), 
                               paste0("Anexo ", 
                                      anexo, 
                                      ", ", 
                                      andar,
                                      "º andar, sala ",
                                      sala), 
                               as.character(NA))) %>% 
    select(id, casa, cpf, nome_civil, nome_eleitoral, genero, uf, sg_partido, situacao, 
           condicao_eleitoral, ultima_legislatura, em_exercicio, data_nascimento, 
           naturalidade, endereco, telefone, email)
  
  return(deputados_alt)
}

#' @title Processa dados de senadores
#' @description Processa informações sobre os senadores da legislatura 56
#' @return Dataframe contendo informações sobre os senadores
#' @examples
#' processa_dados_senadores()
processa_dados_senadores <- function() {
  library(tidyverse)
  library(here)
  source(here::here("crawler/parlamentares/senadores/fetcher_senador.R"))
  
  legislaturas_list <- c(56)
  senadores <- purrr::map_df(legislaturas_list, ~ fetch_senadores_legislatura(.x))
  
  senadores_em_exercicio <- fetch_senadores_atuais(legislatura_atual = 56)
  
  senadores_merge <- senadores %>% 
    left_join(senadores_em_exercicio, by = c("id", "legislatura" = "legislatura_atual")) %>%
    mutate(casa = "senado") %>% 
    mutate(cpf = NA) %>% # Senado não diponibiliza informação do cpf
    mutate(situacao = NA) %>% # Senado não diponibiliza informação da situação
    mutate(genero = dplyr::if_else(genero == "Feminino", "F", "M")) %>%
    mutate(em_exercicio = dplyr::if_else(is.na(em_exercicio), 0, em_exercicio)) %>% 
    
    group_by(id) %>% 
    mutate(ultima_legislatura = max(legislatura)) %>%
    ungroup() %>% 
    
    filter(legislatura == ultima_legislatura) %>%
    select(id, casa, cpf, nome_civil, nome_eleitoral = nome_eleitoral.x, genero, uf, sg_partido, 
           situacao, condicao_eleitoral, ultima_legislatura, em_exercicio, data_nascimento,
           naturalidade, endereco, telefone, email)
  
  return(senadores_merge)
}

#' @title Processa dados de parlamentares
#' @description Processa informações sobre os parlamentares da legislatura atual
#' @return Dataframe contendo informações sobre os parlamentares (deputados e senadores)
#' @examples
#' processa_dados_parlamentares()
processa_dados_parlamentares <- function() {
  deputados <- processa_dados_deputados() %>% 
    ungroup()
  
  senadores <- processa_dados_senadores() %>% 
    ungroup()
  
  parlamentares <- deputados %>% 
    rbind(senadores)
  
  return(parlamentares)
}
