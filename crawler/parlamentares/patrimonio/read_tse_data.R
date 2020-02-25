#' @title Realiza a leitura dos dados para declarações de patrimônio no TSE
#' @description Lê os arquivos de declarações de patrimônio dos candidatos no TSE (padroniza anos de 2014 e 2018).
#' @param patrimonio_datapath Caminho para os dados de patrimônio
#' @return Dataframe contendo declarações de patrimônio padronizadas
#' @examples
#' import_patrimonio_tse(patrimonio_datapath = here::here("crawler/raw_data/dados_tse/bem_candidato_2018_BRASIL.csv.zip"))
#' 
import_patrimonio_tse <- function(
  patrimonio_datapath = here::here("crawler/raw_data/dados_tse/bem_candidato_2018_BRASIL.csv.zip")) {
  
  library(tidyverse)
  library(here)
  
  patrimonio <- read_delim(patrimonio_datapath, delim = ";", 
                  col_types = cols(SQ_CANDIDATO = "c"), locale = locale(encoding = 'latin1', decimal_mark = ",")) %>% 
  select(ano_eleicao = ANO_ELEICAO, nm_tipo_eleicao = NM_TIPO_ELEICAO, ds_eleicao = DS_ELEICAO,
         sigla_uf = SG_UF, sigla_ue = SG_UE, sq_candidato = SQ_CANDIDATO, cd_tipo_bem = CD_TIPO_BEM_CANDIDATO,
         ds_tipo_bem = DS_TIPO_BEM_CANDIDATO, ds_bem = DS_BEM_CANDIDATO, valor_bem = VR_BEM_CANDIDATO)
  
  return(patrimonio)
}

#' @title Realiza a leitura dos dados para candidatos no TSE
#' @description Lê os arquivos dos candidatos no TSE (padroniza anos de 2014 e 2018).
#' @param candidatos_datapath Caminho para os dados de candidatos
#' @return Dataframe contendo informações dos candidatos
#' @examples
#' import_candidatos_tse(candidatos_datapath = here::here("crawler/raw_data/dados_tse/consulta_cand_2018_BRASIL.csv.zip"))
#' 
import_candidatos_tse <- function(
  candidatos_datapath = here::here("crawler/raw_data/dados_tse/consulta_cand_2014_BRASIL.csv.zip")) {
  
  library(tidyverse)
  library(here)
  
  candidatos <- read_delim(candidatos_datapath, delim = ";", 
                           col_types = cols(.default = "c"), locale = locale(encoding = 'latin1'),
                           skip = 1, col_names = FALSE) %>% 
    select(ano_eleicao = X3, nm_tipo_eleicao = X5, ds_eleicao = X8, turno = X6, sigla_uf = X11, sigla_ue = X12, 
           cd_cargo = X14,ds_cargo = X15, sq_candidato = X16, nm_candidato = X18, nm_urna_candidato = X19, 
           cpf_candidato = X21, ds_situacao_candidatura = X24, ds_detalhe_situacao_cand = X26, sg_partido = X29,
           ds_situacao_turno = X54)
    
  return(candidatos)
}
