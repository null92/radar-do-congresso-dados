DROP TABLE IF EXISTS "parlamentares_proposicoes";
DROP TABLE IF EXISTS "proposicoes";

CREATE TABLE IF NOT EXISTS "proposicoes" (
  "id_proposicao_voz" VARCHAR(40),
  "id_proposicao" VARCHAR(40),
  "casa" VARCHAR(255),
  "nome" VARCHAR(255),
  "ano" VARCHAR(4),
  "ementa" VARCHAR(10000),
  "url" VARCHAR(1000),
  PRIMARY KEY("id_proposicao_voz")
);

CREATE TABLE IF NOT EXISTS "parlamentares_proposicoes" (
  "id_proposicao_voz" VARCHAR(40) REFERENCES "proposicoes" ("id_proposicao_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "ordem_assinatura" INTEGER
  --PRIMARY KEY("id_proposicao_voz", "id_parlamentar_voz")
);