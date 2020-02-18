#' @title Processa dados de CEAP na Câmara e no Senado para um ano
#' @description A partir de um ano, a função retorna os gastos com a Cota Parlamentar para a
#' Câmara dos Deputados e Senado Federal
#' @param ano Ano de interesse 
#' @return Dataframe contendo informações sobre os gastos de CEAP no Congresso.
#' @examples
#' processa_gastos_ceap(2019)
processa_gastos_ceap <- function(ano = 2019) {
  library(tidyverse)
  library(here)
  
  source(here("crawler/parlamentares/gastos/fetcher_gastos_ceap.R"))
  source(here("crawler/utils/utils.R"))
  
  gastos_camara <- fetch_gastos_ceap_camara(ano)
  
  gastos_senado <- fetch_gastos_ceap_senado(ano) %>% 
    adiciona_id_senador_dados_ceap()
  
  gastos_congresso <- gastos_camara %>% bind_rows(gastos_senado)
  
  return(gastos_congresso)
  
}

#' @title Adiciona coluna id_parlamentar em dataframe de gastos de CEAP
#' @description A partir do caminho para o dataframe de parlamentares gera um regex com o
#' nome eleitoral e nome civil dos senadores para darem 'match' com o nome do senador que
#' vem do df de gastos de CEAp.
#' @param gastos_senado Dataframe com os dados de gastos CEAP
#' @param parlamentares_datapath Caminho para o dataframe de parlamentares.
#' @return Dataframe de gastos contendo coluna id_parlamentar
adiciona_id_senador_dados_ceap <- function(gastos_senado,
                                           parlamentares_datapath = here::here("crawler/raw_data/parlamentares.csv")) {
  library(tidyverse)
  library(fuzzyjoin)
  
  senadores <- read_csv(parlamentares_datapath) %>% 
    filter(casa == 'senado') %>% 
    mutate(nome_regex = paste0(padroniza_nome(nome_eleitoral), "|", padroniza_nome(nome_civil))) %>% 
    select(id, nome_eleitoral, nome_regex)
  
  senadores_com_id <- gastos_senado %>% 
    mutate(senador = padroniza_nome(senador)) %>% 
    fuzzyjoin::regex_left_join(senadores, by = c("senador" = "nome_regex")) %>% 
    filter(!is.na(id)) %>% 
    select(id_parlamentar = id,
           casa,
           ano,
           mes,
           documento,
           descricao,
           especificacao,
           data_emissao,
           fornecedor,
           cnpj_cpf_fornecedor,
           valor_reembolsado)
  
  return(senadores_com_id)
}
