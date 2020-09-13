#' @title Processa relacionamento de orientações
#' @description Ajusta as orientações vindas da API da câmara e adiciona o voto do líder do Senado como orientação para o Senado.
#' @param votacoes_datapath Caminho para o dataframe de votações
#' @param votos_datapath Caminho para o dataframe de votos
#' @return Dataframe contendo dados das votaçoes editadas
#' @examples
#' relaciona_orientacoes()
relaciona_orientacoes <- function(votacoes_datapath = here::here("crawler/raw_data/votacoes.csv"), votos_datapath = here::here("crawler/raw_data/votos.csv")) {
  library(tidyverse)
  library(fuzzyjoin)
  
  votacoes <- read_csv(votacoes_datapath)
  votos <- read_csv(votos_datapath)
  
  votos_lider <- votos %>% 
    dplyr::filter(id_parlamentar %in% c(5540)) #### Adicionar no array os códigos de lideres passados e novos

  votacoes_camara <- votacoes %>% 
    dplyr::filter(casa == "camara") %>%
    mutate(
      orientacao = case_when(
        str_detect(orientacao, "Não") ~ -1,
        str_detect(orientacao, "Sim") ~ 1,
        str_detect(orientacao, "Obstrução|P-OD") ~ 2,
        str_detect(orientacao, "Abstenção") ~ 3,
        str_detect(orientacao, "Art. 17|art. 51 RISF|Art.17") ~ 4,
        str_detect(orientacao, "Liberado") ~ 5,
        #TODO: Tratar caso P-NRV: Presente mas não registrou foto
        TRUE ~ 0
      )
    )
  
  votacoes_senado <- votacoes %>% 
    dplyr::filter(casa == "senado")
    
  senado_relacionado <- fuzzyjoin::fuzzy_full_join(
    votacoes_senado,
    votos_lider,
    by = c("id_votacao" = "id_votacao"),
    match_fun = list(`==`)
  ) %>%
  mutate(
    id_proposicao = id_proposicao.x,
    id_votacao = id_votacao.x,
    casa = casa.x,
    orientacao = voto
  ) %>%
  select(id_proposicao,id_votacao,casa,obj_votacao,data_hora,votacao_secreta,apelido,status_importante,orientacao,url_votacao)
  
  #####
  ##### Para mudança de liderança 
  #####
  ##### %>% dplyr::filter( (id_parlamentar == 5540 & data_hora <= as.Date("2019/12/31")) | (id_parlamentar == 4560 & data_hora > as.Date("2019/12/31")) )
  #####

  votacoes_total <- rbind(votacoes_camara, senado_relacionado)

  return(votacoes_total)
}

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
votacoes <- relaciona_orientacoes()

message(paste0("Salvando o resultado no diretório ", output_folderpath))
write_csv(votacoes, paste0(output_folderpath, "votacoes_com_orientacao.csv"))

message("Concluído!")