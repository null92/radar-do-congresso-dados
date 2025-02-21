#' @title Processa dados dos parlamentares
#' @description Processa os dados dos parlamentares e retorna no formato correto para o banco de dados
#' @param parlamentares_data_path Caminho para o arquivo de dados dos parlamentares sem tratamento
#' @return Dataframe com informações detalhadas dos parlamentares
processa_parlamentares <- function(parlamentares_data_path = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(here)
  
  source(here::here("crawler/parlamentares/partidos/utils_partidos.R"))
  
  parlamentares <- read_csv(parlamentares_data_path, col_types = cols(cpf = "c", data_nascimento = "c"))

  parlamentares_partidos <- parlamentares %>% 
    group_by(sg_partido) %>% 
    summarise(n = n()) %>% 
    rowwise() %>% 
    mutate(id_partido = map_sigla_id(sg_partido)) %>% 
    ungroup()
  
  parlamentares_alt <- parlamentares %>%
    mutate(situacao = dplyr::if_else(casa == "senado", paste0(condicao_eleitoral, " - ", em_exercicio), situacao)) %>%
    mutate(id_parlamentar_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2),
      id)) %>%
    left_join(parlamentares_partidos %>% select(id_partido, sg_partido), by = c("sg_partido")) %>%
    select(
      id_parlamentar_voz,
      id_parlamentar = id,
      casa,
      cpf,
      nome_civil,
      nome_eleitoral,
      genero,
      uf,
      id_partido,
      situacao,
      condicao_eleitoral,
      ultima_legislatura,
      em_exercicio,
      data_nascimento,
      naturalidade,
      endereco,
      telefone,
      email
    )

  return(parlamentares_alt)
}
