## Radar do Congresso Dados

Este repositório tem o objetivo de processar e disponibilizar os dados utilizados pela aplicação: **Radar do Congresso**.

Esta aplicação foi desenvolvida pelo [Congresso em Foco](https://congressoemfoco.uol.com.br/).

## Sobre o repositório

Este repositório é dividido em dois módulos principais: 
- **Processador dos dados (radar-updater):** Responsável por capturar os dados na API da Câmara e do Senado e processar para o formato utilizado no banco de dados da aplicação. Como resultado final gera CSV's usados com os dados tratados.
- **Gerenciador da atualização dos dados (radar-db):** Responsável por criar os esquemas das tabelas no banco de dados e importar os dados gerados pelo módulo radar-updater.

<br>

## Como levantar o serviço do banco de dados?

Os dados processados se encontram no diretório `bd/data`. Para ter uma versão de um banco de dados com esses dados usados bastar executar os passos a seguir

### Passo 1: Instalar o Docker e o docker-compose

- [docker](https://docs.docker.com/install/linux/docker-ce/ubuntu/#install-docker-ce)
- [docker-compose](https://docs.docker.com/compose/install/)

### Passo 2: Copie as credenciais de acesso ao Banco de dados

Copie o conteúdo do arquivo `.env.sample` para um arquivo `.env` na raiz desse repositório.

Este arquivo contém as credenciais do banco de dados local para desenvolvimento:

```
PGHOST=radar-db
PGUSER=postgres
PGDATABASE=radar
PGPASSWORD=secret
```

### Passo 3: Levante o serviço do banco de dados

Entre no diretório `bd` e execute: 

```
make up
```

Obs: certifique-se que não existe nenhum serviço da sua máquina local executando na porta 5432.

Você pode acessar seu banco de dados local usando o comando (dentro do diretório `bd`):

```
make shell
```

### Passo 4: Criação das tabelas e importação dos dados

Ainda dentro do diretório `bd`, execute o comando que irá criar as tabelas e importar os dados:

```
make create
```

Pronto! Agora seu Banco de dados está com os dados necessários para a aplicação Radar do Congresso.

<br>

## Como atualizar os dados já processados mas que ainda não foram migrados para o banco de dados?

Siga os passos para migrar os dados processados para o Banco de dados.

### Passo 1

Levante o serviço radar-updater executando do diretório raiz do repositório:

```
docker-compose up
```

### Passo 2
Para realizar esta tarefa execute o comando que atualiza os dados no banco de dados com base nos CSV's processados disponíveis em `bd/data`.

De dentro do diretório `bd`, execute:

```
make update
```

Os arquivos de log dessas migrações estarão disponíveis em: `localhost:5421/logs` e são providos pelo servidor de logs.

## Como realizar um novo processamento dos dados?

Para atualizar os dados da aplicação é necessário executar o serviço de atualização provido pelo radar-updater.

Para isto execute de dentro do diretório `bd`:

```
make process-data
```

Provavelmente você irá querer executar agora a migração dos dados para o BD. Para isto execute:

```
make update
```

## Mais sobre a arquitetura docker do projeto

Esta seção irá explicar mais sobre como o docker foi utilizado no projeto.

Existem dois docker-compose no projeto. 
- O primeiro deles na raiz do projeto levanta os serviços referentes ao R para processamento de dados e ao servidor de logs das migrações realizadas no banco de dados.
- O segundo docker-compose está na pasta `bd` e levanta o serviço com o banco de dados.

### Comandos úteis

Para visualizar que containers estão executando:
```
docker ps
```

Para parar a execução de um container:
```
docker stop <id-container>
```

Para forçar regerar a imagem quando uma nova dependência for instalada
```
docker-compose build
```

Para parar os serviços e remover permanentemente os volumes (dados serão perdidos!):

```
docker-compose down --volumes
```
