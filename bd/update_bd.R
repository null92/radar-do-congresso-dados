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
file = here::here("bd/scripts/migrations/migration_partidos.sql")
execute_migration(file, log_file)

## PARLAMENTARES
file = here::here("bd/scripts/migrations/migration_parlamentares.sql")
execute_migration(file, log_file)

## GASTOS CEAP
file = here::here("bd/scripts/migrations/migration_gastos_ceap.sql")
execute_migration(file, log_file)

## PROPOSIÇÕES
file = here::here("bd/scripts/migrations/migration_proposicoes.sql")
execute_migration(file, log_file)

## PARLAMENTARES PROPOSIÇÕES
file = here::here("bd/scripts/migrations/migration_parlamentares_proposicoes.sql")
execute_migration(file, log_file)

## PATRIMONIO
file = here::here("bd/scripts/migrations/migration_patrimonio.sql")

## DISCURSOS
file = here::here("bd/scripts/migrations/migration_discursos.sql")
execute_migration(file, log_file)

if (length(grep("ROLLBACK", readLines(log_file), value = TRUE)) > 0) {
  error <- paste0('Um erro ocorreu durante a execução das migrações. Mais informações em ', log_file)  
  print(error)
} else {
  success <- "As migrações foram realizadas com sucesso!"  
  print(success)
}
