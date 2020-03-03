DROP TABLE IF EXISTS "votos_eleicao";

CREATE TABLE IF NOT EXISTS "votos_eleicao" (
  "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "casa" VARCHAR(40),
  "ano" INTEGER,
  "uf" VARCHAR(4),
  "id_partido" INTEGER REFERENCES "partidos" ("id_partido") ON DELETE SET NULL ON UPDATE CASCADE,
  "total_votos" INTEGER,
  "total_votos_uf" INTEGER,
  "proporcao_votos" REAL,
  PRIMARY KEY ("id_parlamentar_voz", "ano")
);
