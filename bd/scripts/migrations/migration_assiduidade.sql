-- ASSIDUIDADE
BEGIN;

CREATE TEMP TABLE temp_assiduidade AS SELECT * FROM assiduidade LIMIT 0;

\copy temp_assiduidade FROM './data/assiduidade.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO assiduidade
  SELECT * FROM temp_assiduidade
  ON CONFLICT (id_parlamentar_voz, ano) 
  DO
    UPDATE
    SET 
    dias_com_sessoes_deliberativas = EXCLUDED.dias_com_sessoes_deliberativas,
    dias_presentes = EXCLUDED.dias_presentes, 
    dias_ausencias_justificadas = EXCLUDED.dias_ausencias_justificadas, 
    dias_ausencias_nao_justificadas = EXCLUDED.dias_ausencias_nao_justificadas;

DELETE FROM assiduidade
 WHERE (id_parlamentar_voz, ano) NOT IN 
 (SELECT id_parlamentar_voz, ano FROM temp_assiduidade);

DROP TABLE temp_assiduidade;

COMMIT;