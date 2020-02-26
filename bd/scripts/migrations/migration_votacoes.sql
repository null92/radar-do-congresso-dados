-- VOTACOES
BEGIN;

CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes
  SELECT * FROM temp_votacoes
  ON CONFLICT (id_proposicao_voz, id_votacao) 
  DO
    UPDATE
    SET 
      obj_votacao = EXCLUDED.obj_votacao,
      data_hora = EXCLUDED.data_hora,
      votacao_secreta = EXCLUDED.votacao_secreta;

DELETE FROM votacoes
 WHERE (id_proposicao_voz, id_votacao) NOT IN 
 (SELECT id_proposicao_voz, id_votacao FROM temp_votacoes);

DROP TABLE temp_votacoes;

COMMIT;