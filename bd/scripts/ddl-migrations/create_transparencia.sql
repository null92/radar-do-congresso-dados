DROP TABLE IF EXISTS "transparencia";

CREATE TABLE IF NOT EXISTS "transparencia" (
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "casa" VARCHAR(40),
    "estrelas" INTEGER,
    PRIMARY KEY("id_parlamentar_voz")
);