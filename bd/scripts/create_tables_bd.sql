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
