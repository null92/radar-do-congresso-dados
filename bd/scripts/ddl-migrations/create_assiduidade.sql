DROP TABLE IF EXISTS "assiduidade";

CREATE TABLE IF NOT EXISTS "assiduidade" (
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "ano" INTEGER,
    "dias_com_sessoes_deliberativas" INTEGER,
    "dias_presentes" INTEGER, 
    "dias_ausencias_justificadas" INTEGER, 
    "dias_ausencias_nao_justificadas" INTEGER,
    PRIMARY KEY("id_parlamentar_voz", "ano")
);