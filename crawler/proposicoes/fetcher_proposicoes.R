#' @title Baixa dados de proposições apresentadas na Câmara
#' @description Baixa as proposições que foram aprensentadas na 56ª legislatura
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_camara(anos = c(2019, 2020))
fetcher_proposicoes_camara <- function(anos = seq(2019, format(Sys.Date(), "%Y"))) {
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
           id_parlamentar = idDeputadoAutor,
           ordem_assinatura = ordemAssinatura) %>%
    distinct()

  url_proposicoes <- paste0("https://dadosabertos.camara.leg.br/arquivos/proposicoes/csv/proposicoes-", ano, ".csv")

  proposicoes <- read_delim(url_proposicoes, delim = ";") %>%
    filter(id %in% parlamentares_proposicoes$id_proposicao, ano == ano)

  proposicoes_alt <- proposicoes %>%
    mutate(nome = paste0(siglaTipo, " ", numero, "/", ano),
           casa = "camara",
           ano = ano) %>% 
    select(id_proposicao = id,
           casa,
           nome,
           ano,
           ementa,
           url = uri) %>%
    left_join(parlamentares_proposicoes,
              by = "id_proposicao") %>%
    distinct() %>% 
    select(id_proposicao, casa, nome, ano, ementa, url, id_parlamentar, ordem_assinatura)

  return(proposicoes_alt)
}

#' @title Baixa dados de proposições apresentadas no Senado
#' @description Baixa as proposições que foram aprensentadas por Senadores na 56ª legislatura
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_senado(anos = c(2019, 2020))
fetcher_proposicoes_senado <- function(anos = seq(2019, format(Sys.Date(), "%Y"))) {
  library(tidyverse)
  library(here)

  senadores <- read_csv(here::here("crawler/raw_data/parlamentares.csv"),
                        col_types = cols(id = "c")) %>%
    filter(casa == "senado")

  proposicoes_autores <- tibble(id_request = senadores$id) %>%
    mutate(dados = map(
      id_request,
      fetcher_proposicoes_senador,
      anos
    )) %>%
    unnest(dados) %>% 
    select(-id_request)
  
  return(proposicoes_autores)
}

#' @title Baixa dados de proposições apresentadas no Senado por um senador em um conjunto de anos
#' @description Baixa as proposições que foram apresentadas por um senador em um conjunto de anos
#' @param anos Lista com anos de interesse
#' @return Dataframe contendo informações sobre as proposições
#' @examples
#' fetcher_proposicoes_senador(4981, c(2019, 2020))
fetcher_proposicoes_senador <- function(id_senador, anos) {
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
#' fetcher_proposicoes_senador_por_ano(2019, 4981)
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
                    id_parlamentar = character(),
                    ordem_assinatura = character()))
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
            xml2::xml_text(),
          ordem_assinatura = xml2::xml_find_first(x, ".//NumeroOrdemAutor") %>%
            xml2::xml_text()
        )
      }) %>%
      mutate(casa = "senado") %>%
      mutate(url = paste0("https://www25.senado.leg.br/web/atividade/materias/-/materia/",
                                     id_proposicao)) %>%
      mutate(id_parlamentar = id_senador) %>%
      select(id_proposicao, casa, nome, ano, ementa, url, id_parlamentar, ordem_assinatura)

    return(proposicoes)

  }, error = function(e) {
    print(e)
    data <- tibble(id_proposicao = character(),
                   casa = character(),
                   nome = character(),
                   ano = character(),
                   ementa = character(),
                   url = character(),
                   id_parlamentar = character(),
                   ordem_assinatura = character())
    return(data)
  })
}

#' @title Baixa dados de uma proposição pelo seu id
#' @description Baixa as informações sobre uma proposição a partir do seu id
#' @param id_proposicao ID da proposição na Câmara
#' @return Dataframe contendo informações sobre a proposição
#' @examples
#' fetcher_proposicao_por_id_camara(212142)
fetcher_proposicao_por_id_camara <- function(id) {
  library(tidyverse)
  
  print(paste0("Baixando informações da proposição de id ", id))
  
  url <- paste0("https://dadosabertos.camara.leg.br/api/v2/proposicoes/", id)
  
  proposicao <- tryCatch({
    dados <- (RCurl::getURL(url) %>% 
                jsonlite::fromJSON())$dados
    prop <-
      tribble(
        ~ id_proposicao,
        ~ casa,
        ~ nome,
        ~ ano,
        ~ ementa,
        ~ url,
        dados$id,
        "camara",
        paste0(dados$siglaTipo,
               " ",
               dados$numero,
               "/",
               dados$ano),
        dados$ano,
        dados$ementa,
        dados$uri
      )
    
    return(prop)
  }, 
  error = function(e) {
    print(e)
    return(tibble(id_proposicao = character(),
                   casa = character(),
                   nome = character(),
                   ano = character(),
                   ementa = character(),
                   url = character()))
  })
  
  return(proposicao)
}

#' @title Baixa dados de uma proposição pelo seu id
#' @description Baixa as informações sobre uma proposição a partir do seu id
#' @param id_proposicao ID da proposição no Senado
#' @return Dataframe contendo informações sobre a proposição
#' @examples
#' fetcher_proposicao_por_id_senado(91341)
fetcher_proposicao_por_id_senado <- function(id) {
  library(tidyverse)
  library(xml2)
  
  print(paste0("Baixando informações da proposição de id ", id))
  
  url <- paste0("http://legis.senado.leg.br/dadosabertos/materia/", id)
  
  proposicao <- tryCatch({
    xml <- RCurl::getURL(url) %>% xml2::read_xml()
    dado <- xml_find_first(xml, ".//Materia")
    if (dado %>% rlang::is_empty()) {
      return(tibble(id_proposicao = character(),
                    casa = character(),
                    nome = character(),
                    ano = character(),
                    ementa = character(),
                    url = character()))
    }
    prop <- tribble(
      ~ id_proposicao,
      ~ casa,
      ~ nome,
      ~ ano,
      ~ ementa,
      xml_find_first(dado, ".//IdentificacaoMateria//CodigoMateria") %>%
        xml2::xml_text(),
      "senado",
      xml_find_first(
        dado,
        ".//IdentificacaoMateria//DescricaoIdentificacaoMateria"
      ) %>%
        xml2::xml_text(),
      xml_find_first(dado, ".//IdentificacaoMateria//AnoMateria") %>%
        xml2::xml_text(),
      xml2::xml_find_first(dado, ".//EmentaMateria") %>%
        xml2::xml_text()
    ) %>%
      mutate(
        url = paste0(
          "https://www25.senado.leg.br/web/atividade/materias/-/materia/",
          id_proposicao
        )
      )
    
    return(prop)
  }, 
  error = function(e){
    print(e)
    return(tibble(id_proposicao = character(),
                  casa = character(),
                  nome = character(),
                  ano = character(),
                  ementa = character(),
                  url = character()))
  })
  
  return(proposicao)
}
