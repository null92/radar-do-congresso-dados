BEGIN;

DROP TABLE IF EXISTS "patrimonio";

CREATE TABLE IF NOT EXISTS "patrimonio" (
    "id_patrimonio" SERIAL,
    "id_parlamentar_voz" VARCHAR(40) REFERENCES "parlamentares" ("id_parlamentar_voz") ON DELETE CASCADE ON UPDATE CASCADE,
    "casa" VARCHAR(40),
    "ano_eleicao" INTEGER,
    "ds_cargo" VARCHAR(40),
    "ds_tipo_bem" VARCHAR(255),
    "ds_bem" TEXT,
    "valor_bem" DECIMAL(15, 2)
);

COMMIT;