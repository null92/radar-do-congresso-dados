-- transparencia
BEGIN;

CREATE TEMP TABLE temp_transparencia AS SELECT * FROM transparencia LIMIT 0;

\copy temp_transparencia FROM './data/transparencia.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO transparencia
  SELECT * FROM temp_transparencia
  ON CONFLICT (id_parlamentar_voz) 
  DO
    UPDATE
    SET 
    casa = EXCLUDED.casa,
    estrelas = EXCLUDED.estrelas;

DELETE FROM transparencia
 WHERE (id_parlamentar_voz) NOT IN 
 (SELECT id_parlamentar_voz FROM temp_transparencia);

DROP TABLE temp_transparencia;

COMMIT;