library(tidyverse)
library(here)
source(here::here("crawler/parlamentares/gastos/analyzer_gastos_ceap.R"))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-a", "--ano"), type="character", default="2019", 
              help="ano de interesse [default= %default]", metavar="character"),
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/gastos_ceap_congresso.csv"), 
              help="nome do arquivo de saída [default= %default]", metavar="character")
) 

opt_parser = OptionParser(option_list=option_list)
opt = parse_args(opt_parser)

ano = opt$ano
saida <- opt$out

message("Iniciando processamento...")
message("Baixando dados...")

gastos_ceap <- processa_gastos_ceap(2019) %>% rbind(processa_gastos_ceap(2020)) %>% distinct()

message(paste0("Salvando o resultado em ", saida))
write_csv(gastos_ceap, saida)

message("Concluído!")
