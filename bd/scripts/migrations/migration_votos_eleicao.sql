-- VOTOS ELEICAO
BEGIN;
CREATE TEMP TABLE temp_votos_eleicao AS SELECT * FROM votos_eleicao LIMIT 0;

\copy temp_votos_eleicao FROM './data/votos_eleicao.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO votos_eleicao
SELECT *
FROM temp_votos_eleicao
ON CONFLICT (id_parlamentar_voz, ano) 
DO
  UPDATE
  SET 
    casa = EXCLUDED.casa,
    uf = EXCLUDED.id_partido,
    id_partido = EXCLUDED.id_partido,
    total_votos = EXCLUDED.total_votos,
    total_votos_uf = EXCLUDED.total_votos_uf;

DROP TABLE temp_votos_eleicao;
COMMIT;
