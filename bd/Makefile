.DEFAULT_GOAL : help
help:
	@echo "Radar do Congresso"
	@echo "Este arquivo facilita a execução de comandos do módulo de configuração e gerenciamento do bando de dados"	
	@echo "Para executar basta 'make <command>'"
	@echo "    "	
	@echo "    help - Exibe esta mensagem de ajuda"
	@echo "    "	
	@echo "    up"
	@echo "        Levanta o serviço com o banco de dados"	
	@echo "    "
	@echo "    create"
	@echo "        Cria tabelas no banco de dados e importa dados"	
	@echo "    "
	@echo "    stop"
	@echo "        Para serviço do banco de dados"
	@echo "    "		
	@echo "    clean"
	@echo "        Para o serviço de banco de dados e remove os dados carregados nas tabelas"
	@echo "    "	
	@echo "    sh"
	@echo "        Abre uma sessão sh diretamente do container executando o banco de dados	"
	@echo "    "	
	@echo "    update"
	@echo "        Atualiza banco de dados usando serviço radar-updater (precisa estar executando)."
	@echo "    "	
	@echo "    process-data"
	@echo "        Processa dados usando o serviço de dados do Radar do congresso"
	@echo "    "	
	@echo "    shell"
	@echo "        Abre uma sessão no shell do postgres executando	"
	@echo "    "	
.PHONY: help
create:
	docker-compose exec radar-db psql -U postgres -d radar -1 -f scripts/create_tables_bd.sql
	docker-compose exec radar-db psql -U postgres -d radar -1 -f scripts/import_csvs_bd.sql
.PHONY: create
stop:
	docker-compose stop
.PHONY: stop
up:
	docker-compose up
.PHONY: up
clean:
	docker-compose down --volumes
.PHONY: clean
clean-all:
	docker-compose down --volumes
.PHONY: clean-all
sh:
	docker exec -it radar-db-container sh
.PHONY: sh
update:
	docker exec -it radar-updater-container sh -c "cd /app/bd && Rscript update_bd.R"
.PHONY: update
process-data:
	docker exec -it radar-updater-container sh -c "cd /app/bd && Rscript update_data.R"
.PHONY: process-data
shell:
	docker exec -it radar-db-container sh -c "psql -U postgres -d radar -U postgres"
.PHONY: shell
