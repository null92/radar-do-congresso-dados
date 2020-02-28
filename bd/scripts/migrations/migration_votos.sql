-- VOTACOES
BEGIN;

CREATE TEMP TABLE temp_votos AS SELECT * FROM votos LIMIT 0;

\copy temp_votos FROM './data/votos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO votos
  SELECT * FROM temp_votos
  ON CONFLICT (id_votacao, id_parlamentar_voz) 
  DO
    UPDATE
    SET 
      voto = EXCLUDED.voto;

DROP TABLE temp_votos;

COMMIT;