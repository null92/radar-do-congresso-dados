DROP TABLE IF EXISTS "votos";

CREATE TABLE IF NOT EXISTS "votos" (
    "id_votacao" VARCHAR(40) REFERENCES "votacoes"("id_votacao") ON DELETE CASCADE ON UPDATE CASCADE,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "voto" INTEGER,
    PRIMARY KEY("id_votacao", "id_parlamentar_voz")
);