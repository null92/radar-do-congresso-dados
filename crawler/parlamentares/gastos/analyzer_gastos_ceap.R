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
  
  source(here::here("crawler/parlamentares/gastos/fetcher_gastos_ceap.R"))
  source(here::here("crawler/utils/utils.R"))
  
  gastos_camara <- fetch_gastos_ceap_camara(ano)
  
  gastos_camara <- gastos_camara %>% 
    classifica_classes_gastos_ceap_camara() %>% 
    select(id_parlamentar, casa, ano, mes, data_emissao, documento, categoria, especificacao = descricao,
           fornecedor, cnpj_cpf_fornecedor, valor_gasto = valor_liquido) %>% 
    distinct()
  
  gastos_senado <- fetch_gastos_ceap_senado(ano)
  
  gastos_senado <- gastos_senado %>%
    adiciona_id_senador_dados_ceap() %>% 
    classifica_classes_gastos_ceap_senado() %>% 
    select(id_parlamentar, casa, ano, mes, data_emissao, documento, categoria, especificacao,
           fornecedor, cnpj_cpf_fornecedor, valor_gasto = valor_reembolsado) %>% 
    distinct()
  
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
    mutate(nome_regex = paste0(
      padroniza_nome(nome_eleitoral),
      "|",
      padroniza_nome(nome_civil)
    )) %>%
    select(id, nome_eleitoral, nome_regex)
  
  senadores_com_id <- gastos_senado %>%
    mutate(senador = padroniza_nome(senador)) %>%
    fuzzyjoin::regex_left_join(senadores, by = c("senador" = "nome_regex")) %>%
    filter(!is.na(id)) %>%
    select(
      id_parlamentar = id,
      casa,
      ano,
      mes,
      documento,
      descricao,
      especificacao,
      data_emissao,
      fornecedor,
      cnpj_cpf_fornecedor,
      valor_reembolsado
    )
  
  return(senadores_com_id)
}

#' @title Classifica as categorias de gastos em Superclasses na Câmara
#' @description A partir do dataframe de gastos de ceap dos deputados, retorna um dataframe
#' contendo as categorias de gastos definidas como: Alimentação,
#' Combustíveis, Locação de veículos, Passagens aéreas,
#' Escritório e Divulgação.
#' @param gastos_camara Dataframe com os dados de gastos CEAP na Câmara
#' @return Dataframes de gastos contendo coluna categoria dos gastos.
classifica_classes_gastos_ceap_camara <- function(gastos_camara) {
  library(tidyverse)
  
  mapeamento_classes <- jsonlite::fromJSON(
    here::here(
      "crawler/parlamentares/gastos/mapeamento_superclasses_gastos.json"
    )
  )
  
  gastos_camara_alt <- fuzzyjoin::regex_left_join(
    gastos_camara %>% 
      mutate(descricao_alt = tolower(descricao)),
    mapeamento_classes$superclasses_camara %>% 
      mutate(subclasse = tolower(subclasse)),
    by = c("descricao_alt" = "subclasse")
  ) %>%
    mutate(categoria = if_else(is.na(categoria),
                               "Outros",
                               categoria)) %>% 
    select(-descricao_alt)
  
  return(gastos_camara_alt)
  
}

#' @title Classifica as categorias de gastos em Superclasses no Senado
#' @description A partir do dataframe de gastos de ceap dos senadores, retorna um dataframe
#' contendo as categorias de gastos definidas como: Alimentação,
#' Combustíveis, Locação de veículos, Passagens aéreas,
#' Escritório e Divulgação.
#' @param gastos_senado Dataframe com os dados de gastos CEAP no Senado
#' @return Dataframes de gastos contendo coluna categoria dos gastos.
classifica_classes_gastos_ceap_senado <- function(gastos_senado) {
  library(tidyverse)
  
  mapeamento_classes <- jsonlite::fromJSON(here::here(
    "crawler/parlamentares/gastos/mapeamento_superclasses_gastos.json"
  ))
  
  # Existe uma descrição muito genérica que engloba várias categorias,
  # então usaremos a especificação nesse caso.
  gastos_senado <- gastos_senado %>%
    mutate(
      descricao = if_else(
        descricao == "Locomoção, hospedagem, alimentação, combustíveis e lubrificantes",
        especificacao,
        descricao
      )
    ) %>%
    filter(descricao != '-')
  
  gastos_senado_alt <- fuzzyjoin::regex_left_join(
    gastos_senado %>%
      mutate(descricao = tolower(descricao)),
    mapeamento_classes$superclasses_senado %>%
      mutate(subclasse = tolower(subclasse)),
    by = c("descricao" = "subclasse")
  ) %>%
    mutate(categoria = if_else(is.na(categoria),
                               "Outros",
                               categoria))
  
  gastos_senado_alt <- gastos_senado_alt %>%
    left_join(mapeamento_classes$ordem_precedencia_superclasses_senado,
              by = "categoria") %>%
    group_by(
      id_parlamentar,
      casa,
      ano,
      mes,
      documento,
      descricao,
      especificacao,
      data_emissao,
      fornecedor,
      cnpj_cpf_fornecedor,
      valor_reembolsado
    ) %>%
    mutate(min_ordem = min(ordem)) %>%
    filter(ordem == min_ordem) %>%
    ungroup() %>%
    distinct() %>%
    select(-c(subclasse, ordem, min_ordem))
  
  return(gastos_senado_alt)
  
}
