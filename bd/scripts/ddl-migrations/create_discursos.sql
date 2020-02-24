DROP TABLE IF EXISTS "discursos";

CREATE TABLE IF NOT EXISTS "discursos" (
  "id_discurso" SERIAL,
  "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
  "casa" VARCHAR(40),
  "tipo" VARCHAR(255),
  "data" DATE,
  "local" VARCHAR(255),
  "resumo" TEXT,
  "link" VARCHAR(255)
);
