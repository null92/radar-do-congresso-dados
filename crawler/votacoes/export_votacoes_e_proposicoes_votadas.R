suppressWarnings(suppressMessages(source(here::here("crawler/votacoes/analyzer_votacoes_e_proposicoes_votadas.R"))))

if(!require(optparse)){
  install.packages("optparse")
  suppressWarnings(suppressMessages(library(optparse)))
}

args = commandArgs(trailingOnly=TRUE)

message("LEIA O README deste diretório")
message("Use --help para mais informações\n")

option_list = list(
  make_option(c("-o", "--out"), type="character", default=here::here("crawler/raw_data/"),
              help="nome da pasta onde os arquivos serão salvos [default= %default]", metavar="character")
);

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

output_folderpath <- opt$out

message("Iniciando processamento...")
votacoes_e_proposicoes <- process_proposicoes_votadas_e_votacoes()

proposicoes <- votacoes_e_proposicoes[[1]]
votacoes <- votacoes_e_proposicoes[[2]]

message(paste0("Salvando o resultado no diretório ", output_folderpath))
write_csv(proposicoes, paste0(output_folderpath, "proosicoes_votadas.csv"))
write_csv(votacoes, paste0(output_folderpath, "votacoes.csv"))

message("Concluído!")
