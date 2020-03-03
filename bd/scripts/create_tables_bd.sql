CREATE TABLE IF NOT EXISTS "partidos" (    
    "id_partido" INTEGER,
    "sigla" VARCHAR(255),
    "tipo" VARCHAR(90),
    "situacao" VARCHAR(60),
    PRIMARY KEY("id_partido")
);

CREATE TABLE IF NOT EXISTS "parlamentares" (
    "id_parlamentar_voz" VARCHAR(40),
    "id_parlamentar" VARCHAR(40) DEFAULT NULL,
    "casa" VARCHAR(255),
    "cpf" VARCHAR(255),
    "nome_civil" VARCHAR(255),
    "nome_eleitoral" VARCHAR(255),
    "genero" VARCHAR(255),
    "uf" VARCHAR(255),
    "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
    "situacao" VARCHAR(255),
    "condicao_eleitoral" VARCHAR(255),
    "ultima_legislatura" VARCHAR(255),
    "em_exercicio" BOOLEAN,
    PRIMARY KEY("id_parlamentar_voz")
);  

CREATE TABLE IF NOT EXISTS "gastos_ceap" (
    "id" SERIAL,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE SET NULL ON UPDATE CASCADE,
    "casa" VARCHAR(255),
    "ano" INTEGER,
    "mes" INTEGER,
    "documento" VARCHAR(400),
    "categoria" VARCHAR(800),
    "especificacao" VARCHAR(1500),
    "data_emissao" DATE,
    "fornecedor" VARCHAR(255),
    "cnpj_cpf_fornecedor" VARCHAR(255),
    "valor_gasto" NUMERIC(15, 2),
    PRIMARY KEY("id")
);  

CREATE TABLE IF NOT EXISTS "proposicoes" (
    "id_proposicao_voz" VARCHAR(40),
    "id_proposicao" VARCHAR(40),
    "casa" VARCHAR(255),
    "nome" VARCHAR(255),
    "ano"  VARCHAR(4),
    "ementa" VARCHAR(4000),
    "url" VARCHAR(1000),
    PRIMARY KEY("id_proposicao_voz")
);

CREATE TABLE IF NOT EXISTS "parlamentares_proposicoes" (
    "id_proposicao_voz" VARCHAR(40) REFERENCES "proposicoes" ("id_proposicao_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "ordem_assinatura" INTEGER,
    PRIMARY KEY("id_proposicao_voz", "id_parlamentar_voz")
);

CREATE TABLE IF NOT EXISTS "patrimonio" (
    "id_patrimonio" SERIAL,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "casa" VARCHAR(40),
    "ano_eleicao" INTEGER,
    "ds_cargo" VARCHAR(40),
    "ds_tipo_bem" VARCHAR(255),
    "ds_bem" TEXT,
    "valor_bem" DECIMAL(15, 2),
    PRIMARY KEY("id_patrimonio")
);

CREATE TABLE IF NOT EXISTS "discursos" (
  "id_discurso" SERIAL,
  "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "casa" VARCHAR(40),
  "tipo" VARCHAR(255),
  "data" DATE,
  "local" VARCHAR(255),
  "resumo" TEXT,
  "link" VARCHAR(255),
  PRIMARY KEY("id_discurso")
);

CREATE TABLE IF NOT EXISTS "votacoes" (
    "id_proposicao_voz" VARCHAR(40) REFERENCES "proposicoes" ("id_proposicao_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_votacao" VARCHAR(40) UNIQUE,
    "casa" VARCHAR(255),
    "obj_votacao" VARCHAR(500),
    "data_hora" DATE,
    "votacao_secreta" BOOLEAN,
    "url_votacao" VARCHAR(500),
    PRIMARY KEY("id_votacao")
);

CREATE TABLE IF NOT EXISTS "votos" (
    "id_votacao" VARCHAR(40) REFERENCES "votacoes"("id_votacao") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "voto" INTEGER,
    PRIMARY KEY("id_votacao", "id_parlamentar_voz")
);

CREATE TABLE IF NOT EXISTS "votos_eleicao" (
  "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "casa" VARCHAR(40),
  "ano" INTEGER,
  "total_votos" INTEGER,
  "total_votos_uf" INTEGER,
  "proporcao_votos" REAL,
  PRIMARY KEY ("id_parlamentar_voz", "ano")
);

