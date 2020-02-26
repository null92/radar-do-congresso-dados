library(tidyverse)	
library(here)	

 if(!require(optparse)){	
  install.packages("optparse")	
  library(optparse)	
}	

 message("Leia o README deste diretório")	
message("Use --help para mais informações\n")	

 option_list <- list(	
  make_option(c("-o", "--output"), 	
              type="character", 	
              default=here::here("bd/data/"), 	
              help="diretório de saída [default= %default]", 	
              metavar="character")	
)	

opt_parser <- OptionParser(option_list=option_list)	

opt <- parse_args(opt_parser)	

output <- opt$output	

message("Processando dados...")	

source(here("bd/processor/parlamentares/processa_parlamentares.R"))
parlamentares <- processa_parlamentares()

source(here("bd/processor/partidos/processa_partidos.R"))
partidos <- processa_partidos()

source(here("bd/processor/gastos_ceap/processa_gastos_ceap.R"))
gastos_ceap <- processa_gastos_ceap()

source(here("bd/processor/proposicoes/processa_proposicoes.R"))
proposicoes <- processa_proposicoes()

source(here("bd/processor/parlamentares_proposicoes/processa_parlamentares_proposicoes.R"))
parlamentares_proposicoes <- processa_parlamentares_proposicoes()

source(here("bd/processor/votacoes/processa_votacoes.R"))
votacoes <- processa_votacoes()

message("Escrevendo dados em csv...")	
write_csv(parlamentares, paste0(output, "parlamentares.csv"))
write_csv(partidos, paste0(output, "partidos.csv"))
write_csv(gastos_ceap, paste0(output, "gastos_ceap_congresso.csv"))
write_csv(proposicoes, paste0(output, "proposicoes.csv"))
write_csv(votacoes, paste0(output, "votacoes.csv"))

message("Concluído")
