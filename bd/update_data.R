library(tidyverse)
library(here)
Sys.setenv(TZ='America/Recife')

tryCatch(
  {
    message(date(), " - Executando crawler de Parlamentares...\n")
    source(here::here("crawler/parlamentares/export_parlamentares.R"))
  },
  error=function(cond) {
    log_error <- paste(cond, "Um erro ocorreu durante a execução do crawler de Parlamentares")
    message(log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    message(date(), " - Executando crawler de Partidos...\n")
    source(here::here("crawler/parlamentares/partidos/export_partidos.R"))
  },
  error=function(cond) {
    log_error <- paste(cond, "Um erro ocorreu durante a execução do crawler de Partidos")
    message(log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    message(date(), " - Executando crawler de Gastos com CEAP...\n")
    source(here::here("crawler/parlamentares/gastos/export_gastos_ceap.R"))
  },
  error=function(cond) {
    log_error <- paste(cond, "Um erro ocorreu durante a execução do crawler de Gastos com CEAP")
    message(log_error)
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

tryCatch(
  {
    message(date(), " - Executando processamento dos dados para o formato do BD...\n")
    source(here::here("bd/export_dados_tratados_bd.R"))
  },
  error=function(cond) {
    log_error <- paste(cond, "Um erro ocorreu durante o processamento dos dados para o formato do BD")
    message(log_error)    
    stop("A execução foi interrompida", call. = FALSE)
    return(NA)
  }
)

success <- "A Atualização dos dados foi realizada com sucesso!"
print(success)
