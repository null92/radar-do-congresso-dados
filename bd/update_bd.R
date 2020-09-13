library(tidyverse)
Sys.setenv(TZ='America/Recife')

host <- Sys.getenv("PGHOST")
user <- Sys.getenv("PGUSER")
database <- Sys.getenv("PGDATABASE")
## password env PGPASSWORD

execute_migration <- function(migration, log_output) {
  system(paste0('psql -h ', host, ' -U ', user, ' -d ', database, ' -f ', migration,
                ' -a -b -e >> ', log_output, ' 2>&1'))
  write_log("=======================================================", log_output)
}

write_log <- function(message, log_output) {
  system(paste0('echo ', message, ' >> ', log_output))
}

log_file <- here::here(paste0("bd/scripts/logs/",  gsub(":", "", gsub(" ", "_", Sys.time())), "_log.txt"))

write_log(Sys.time(), log_file)
write_log("=======================================================", log_file)

## PARTIDOS
message("Parte 01/11 - Migrando dados: Partidos...")
file = here::here("bd/scripts/migrations/migration_partidos.sql")
execute_migration(file, log_file)

## PARLAMENTARES
message("Parte 02/11 - Migrando dados: Parlamentares...")
file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
execute_migration(file, log_file)

## GASTOS CEAP
message("Parte 03/11 - Migrando dados: Gastos...")
file = here::here("bd/scripts/migrations/migration_gastos_ceap.sql")
execute_migration(file, log_file)

## PROPOSIÇÕES
message("Parte 04/11 - Migrando dados: Proposições...")
file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
execute_migration(file, log_file)

## PARLAMENTARES PROPOSIÇÕES
message("Parte 05/11 - Migrando dados: Parlamentares - Proposições...")
file = here::here("bd/scripts/migrations/migration_parlamentares_proposicoes.sql")
execute_migration(file, log_file)

## PATRIMONIO
message("Parte 06/11 - Migrando dados: Patrimônio...")
file = here::here("bd/scripts/migrations/migration_patrimonio.sql")
execute_migration(file, log_file)

## DISCURSOS
message("Parte 07/11 - Migrando dados: Discursos...")
file = here::here("bd/scripts/migrations/migration_discursos.sql")
execute_migration(file, log_file)

## VOTAÇÕES
message("Parte 08/11 - Migrando dados: Votações...")
file = here::here("bd/scripts/migrations/migration_votacoes.sql")
execute_migration(file, log_file)

## VOTOS
message("Parte 09/11 - Migrando dados: Votos...")
file = here::here("bd/scripts/migrations/migration_votos.sql")
execute_migration(file, log_file)

## VOTOS ELEIÇÃO
message("Parte 10/11 - Migrando dados: Votos - Eleição...")
file = here::here("bd/scripts/migrations/migration_votos_eleicao.sql")
execute_migration(file, log_file)

## ASSIDUIDADE
message("Parte 11/11 - Migrando dados: Assiduidade...")
file = here::here("bd/scripts/migrations/migration_assiduidade.sql")
execute_migration(file, log_file)

## Transparencia
message("Parte 11/11 - Migrando dados: Transparencia...")
file = here::here("bd/scripts/migrations/migration_transparencia.sql")
execute_migration(file, log_file)

if (length(grep("ROLLBACK", readLines(log_file), value = TRUE)) > 0) {
  error <- paste0('Um erro ocorreu durante a execução das migrações. Mais informações em ', log_file)  
  message(error)
} else {
  success <- "As migrações foram realizadas com sucesso!"  
  message(success)
}
