-- PROPOSIÇÕES
BEGIN;

CREATE TEMP TABLE temp_proposicoes AS SELECT * FROM proposicoes LIMIT 0;

\copy temp_proposicoes FROM './data/proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO proposicoes
SELECT *
FROM temp_proposicoes
ON CONFLICT (id_proposicao_voz)
DO
  UPDATE
  SET 
    nome = EXCLUDED.nome,
    ano = EXCLUDED.ano,
    ementa = EXCLUDED.ementa,
    url = EXCLUDED.url;

DELETE FROM proposicoes
 WHERE id_proposicao_voz NOT IN 
 (SELECT id_proposicao_voz FROM temp_proposicoes);

DROP TABLE temp_proposicoes;

COMMIT;