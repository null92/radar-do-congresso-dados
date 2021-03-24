
# sudo docker exec -it radar-updater-container sh -c "cd /app/bd && Rscript test.R"

library(tidyverse)
library(here)
Sys.setenv(TZ='America/Recife')

tryCatch(
  {
    ano = 2019;
    library(tidyverse)
    source(here::here("crawler/votacoes/utils_votacoes.R"))

    url_orientacoes <- paste0("http://dadosabertos.camara.leg.br/arquivos/votacoesOrientacoes/csv/votacoesOrientacoes-",ano,".csv")
    orientacoes <- read_delim(url_orientacoes, delim = ";") %>%
                    filter(siglaBancada == "Governo" | siglaBancada == "GOV.") %>%
                    mutate(id_votacao = idVotacao, orientacao = get_val_voto(orientacao)) %>%
                    select(id_votacao, orientacao)


    url_votacoes <- paste0("http://dadosabertos.camara.leg.br/arquivos/votacoes/csv/votacoes-",ano,".csv")
    votacoes <- read_delim(url_votacoes, delim = ";") %>%
      mutate(
        id_proposicao = as.character(sapply(strsplit(id,"-"), `[`, 1)),
        id_votacao = id,
        obj_votacao = ifelse(nchar(ultimaApresentacaoProposicao_descricao) > 150, paste0(substring(ultimaApresentacaoProposicao_descricao, 1, 147), "..."), ultimaApresentacaoProposicao_descricao),
        data = as.Date(data, format = "%Y-%m-%d"),
        data_hora = dataHoraRegistro,
        apelido = NA,
        status_importante = 0
      ) %>%
      select(
        id_proposicao,
        id_votacao,
        obj_votacao,
        data,
        data_hora,
        apelido,
        status_importante
      ) 

    votacoes_orientadas <- merge(votacoes, orientacoes, by="id_votacao")

    write_csv(votacoes_orientadas, "votacoes_orientadas.csv")

  },
  error=function(cond) {
    log_error <- paste(cond, "Um erro ocorreu durante a execução do crawler")
    message(log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

success <- "A Atualização dos dados foi realizada com sucesso!"
print(success)