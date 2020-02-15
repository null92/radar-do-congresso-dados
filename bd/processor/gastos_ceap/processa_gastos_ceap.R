#' @title Processa dados de gastos ceap dos parlamentares
#' @description Processa os dados de gastos com a cota parlamentar e retorna no formato correto para o banco de dados
#' @param parlamentares_data_path Caminho para o arquivo de dados dos parlamentares já processados
#' @param gastos_data_path Caminho para o arquivo de dados dos gastos sem tratamento
#' @return Dataframe com informações detalhadas dos gastos com ceap
processa_gastos_ceap <- function(
  parlamentares_data_path = here::here("bd/data/parlamentares.csv"),
  gastos_data_path = here::here("crawler/raw_data/gastos_ceap_congresso.csv")) {
  library(tidyverse)
  library(here)
  
  gastos_ceap <- read_csv(gastos_data_path, col_types = cols(.default = "c"))
  
  parlamentares_processados <- read_csv(parlamentares_data_path, 
                                        col_types = cols(id_parlamentar_voz = "c")) %>% 
    pull(id_parlamentar_voz)
  
  gastos_ceap_alt <- gastos_ceap %>% 
    mutate(id_parlamentar_voz = paste0(
      dplyr::if_else(casa == "camara", 1, 2), id_parlamentar)) %>%
    filter(id_parlamentar_voz %in% parlamentares_processados) %>% 
    rowid_to_column("id") %>% 
    select(
      id,
      id_parlamentar_voz,
      casa,
      ano,
      mes,
      documento,
      descricao,
      especificacao,
      data_emissao,
      fornecedor,
      cnpj_cpf_fornecedor,
      valor_documento,
      valor_glosa,
      valor_liquido,
      num_parcela,
      valor_reembolsado
    )
  
  return(gastos_ceap_alt)
}
