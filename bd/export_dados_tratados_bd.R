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

message("Escrevendo dados em csv...")	
write_csv(parlamentares, paste0(output, "parlamentares.csv"))
write_csv(partidos, paste0(output, "partidos.csv"))

message("Concluído")
