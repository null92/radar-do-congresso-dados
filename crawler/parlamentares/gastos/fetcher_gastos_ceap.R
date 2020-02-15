#' @title Baixa dados de CEAP na Câmara para um ano
#' @description A partir de um ano, a função retorna os gastos com a Cota Parlamentar para a
#' Câmara dos Deputados
#' @param ano Ano de interesse
#' @param zip_folderpath Caminho para o zip do csv. Se já foi baixado uma vez, não
#' precisará baixar os dados novamente
#' @return Dataframe contendo informações sobre os gastos de CEAP na Câmara
#' @examples
#' fetch_gastos_ceap_camara(2019)
fetch_gastos_ceap_camara <- function(ano = 2019,
                                     zip_folderpath = here::here("crawler/raw_data/gastos_ceap/")) {
  library(tidyverse)
  
  zip_filepath <- paste0(zip_folderpath, "gastos_ceap_camara_", ano, ".csv.zip")
  
  if(!file.exists(zip_filepath)) {
    url <- paste0("http://www.camara.leg.br/cotas/Ano-", ano, ".csv.zip")
    output_filepath <- paste0(zip_filepath)
    download.file(url, zip_filepath, mode="wb")
  }
  
  gastos_ceap <- read_csv2(zip_filepath, col_types = cols(.default = "c"))
  
  gastos_ceap_alt <- gastos_ceap %>% 
    filter(!is.na(ideCadastro)) %>% 
    mutate(casa = "camara") %>% 
    select(id_parlamentar = ideCadastro, 
           casa,
           ano = numAno,
           mes = numMes,
           documento = txtNumero,
           descricao = txtDescricao, 
           especificacao = txtDescricaoEspecificacao, 
           data_emissao = datEmissao,
           fornecedor = txtFornecedor, 
           cnpj_cpf_fornecedor = txtCNPJCPF,
           valor_documento = vlrDocumento,
           valor_glosa = vlrGlosa,
           valor_liquido = vlrLiquido,
           num_parcela = numParcela,
           valor_reembolsado = vlrRestituicao) %>% 
    mutate_at(.vars = vars(valor_documento:valor_liquido, valor_reembolsado), 
              as.double) %>% 
    mutate(data_emissao = lubridate::as_date(data_emissao))
  
  return(gastos_ceap_alt)
}

#' @title Baixa dados de CEAP no Senado para um ano
#' @description A partir de um ano, a função retorna os gastos com a Cota Parlamentar para o
#' Senadao Federal
#' @param ano Ano de interesse
#' @return Dataframe contendo informações sobre os gastos de CEAP no Senado
#' @examples
#' fetch_gastos_ceap_senado(2019)
fetch_gastos_ceap_senado <- function(ano = 2019) {
  library(tidyverse)
  
  url <- paste0("http://www.senado.gov.br/transparencia/LAI/verba/", ano, ".csv")
  
  gastos_ceap <- read_csv2(url, col_types = cols(.default = "c"), locale = locale(encoding = "latin1"), skip = 1)
  
  names(gastos_ceap) <- names(gastos_ceap) %>% tolower()
  gastos_ceap_alt <- gastos_ceap %>% 
    filter(!is.na(senador)) %>% 
    mutate(casa = "senado") %>% 
    select(senador, 
           casa,
           ano,
           mes, 
           documento, 
           descricao = tipo_despesa, 
           especificacao = detalhamento, 
           data_emissao = data, 
           fornecedor, 
           cnpj_cpf_fornecedor = cnpj_cpf,
           valor_reembolsado) %>% 
    mutate(data_emissao = lubridate::dmy(data_emissao),
           valor_reembolsado = str_replace(valor_reembolsado, "^,", "0."), # ',1' passa a ser '0.1'
           valor_reembolsado = str_replace(valor_reembolsado, ",", "."), # Substitui vírgula por ponto
           valor_reembolsado = as.numeric(valor_reembolsado))
  
  return(gastos_ceap_alt)
}
