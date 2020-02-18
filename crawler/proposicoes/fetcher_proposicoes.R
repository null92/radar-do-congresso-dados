#' @title Baixa dados de proposições apresentadas na Câmara
#' @description Baixa as proposições que foram aprensentadas na 56ª legislatura
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_camara(anos = c(2019, 2020))
fetcher_proposicoes_camara <- function(anos = seq(2019, 2020)) {
  library(tidyverse)

  proposicoes <- purrr::map_df(anos, ~ fetcher_proposicoes_por_ano_camara(.x))

  return(proposicoes)
}

#' @title Baixa dados de proposições apresentadas na Câmara em um ano
#' @description Baixa as proposições que foram aprensentadas em um ano
#' @param ano Ano de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_por_ano_camara(2019)
fetcher_proposicoes_por_ano_camara <- function(ano) {
  library(tidyverse)

  url_parlamentares_proposicoes <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoesAutores/csv/proposicoesAutores-", ano, ".csv")

  parlamentares_proposicoes <- read_delim(url_parlamentares_proposicoes, delim = ";") %>%
    filter(tipoAutor == "Deputado", !is.na(idDeputadoAutor))

  parlamentares_proposicoes <- parlamentares_proposicoes %>%
    select(id_proposicao = idProposicao,
           id_parlamentar = idDeputadoAutor) %>%
    distinct()

  url_proposicoes <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-", ano, ".csv")

  proposicoes <- read_delim(url_proposicoes, delim = ";") %>%
    filter(id %in% parlamentares_proposicoes$id_proposicao, ano == ano)

  proposicoes_alt <- proposicoes %>%
    mutate(nome = paste0(siglaTipo, " ", numero, "/", ano),
           casa = "camara") %>%
    select(id_proposicao = id,
           casa,
           nome,
           data_apresentacao = dataApresentacao,
           ementa,
           url = uri) %>%
    left_join(parlamentares_proposicoes,
              by = "id_proposicao") %>%
    distinct()

  return(proposicoes_alt)
}


fetcher_proposicoes_senado <- function(anos = seq(2019, 2020)) {
  library(tidyverse)
  library(here)

  senadores <- read_csv(here("crawler/raw_data/parlamentares.csv"),
                        col_types = cols(id = "c")) %>%
    filter(casa == "senado")

  date()
  proposicoes_autores <- tibble(id_request = senadores$id) %>%
    mutate(dados = map(
      id_request,
      fetcher_proposicoes_senador_anos,
      anos
    )) %>%
    unnest(dados)
  date()

}

fetcher_proposicoes_senador_anos <- function(id_senador, anos) {
  library(tidyverse)

  proposicoes <- tibble(ano_request = anos) %>%
    mutate(dados = map(
      ano_request,
      fetcher_proposicoes_senador_por_ano,
      id_senador
    )) %>%
    unnest(dados) %>%
    select(-ano_request)

  return(proposicoes)
}

#' @title Baixa dados de proposições apresentadas no Senado por um senador em um ano
#' @description Baixa as proposições que foram apresentadas por um senador em um ano
#' @param ano Ano de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_senador_por_ano(4981, 2019)
fetcher_proposicoes_senador_por_ano <- function(ano, id_senador) {
  library(tidyverse)

  url <- paste0("http://legis.senado.leg.br/dadosabertos/senador/", id_senador, "/autorias?ano=", ano)

  print(paste0("Baixando proposições de autoria do senador ", id_senador, " para o ano de ", ano))

  tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    if (xml2::xml_find_all(xml, ".//Materia") %>% rlang::is_empty()) {
      return(tibble(id_proposicao = character(),
                    casa = character(),
                    nome = character(),
                    ano = character(),
                    ementa = character(),
                    url = character(),
                    id_parlamentar = character()))
    }
    proposicoes <- xml2::xml_find_all(xml, ".//Materia") %>%
      map_df(function(x) {
        list(
          id_proposicao = xml2::xml_find_first(x, ".//IdentificacaoMateria//CodigoMateria") %>%
            xml2::xml_text(),
          nome = xml2::xml_find_first(x, ".//IdentificacaoMateria//DescricaoIdentificacaoMateria") %>%
            xml2::xml_text(),
          ano = xml2::xml_find_first(x, ".//IdentificacaoMateria//AnoMateria") %>%
            xml2::xml_text(),
          ementa = xml2::xml_find_first(x, ".//EmentaMateria") %>%
            xml2::xml_text()
        )
      }) %>%
      mutate(casa = "camara") %>%
      mutate(url = paste0("https://www25.senado.leg.br/web/atividade/materias/-/materia/",
                                     id_proposicao)) %>%
      mutate(id_parlamentar = id_senador) %>%
      select(id_proposicao, casa, nome, ano, ementa, url, id_parlamentar)

    return(proposicoes)

  }, error = function(e) {
    print(e)
    data <- tibble(id_proposicao = character(),
                   casa = character(),
                   nome = character(),
                   ano = character(),
                   ementa = character(),
                   url = character(),
                   id_parlamentar = character())
    return(data)
  })
}
