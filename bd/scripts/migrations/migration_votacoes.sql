-- VOTACOES
BEGIN;

CREATE TEMP TABLE temp_votacoes AS SELECT * FROM votacoes LIMIT 0;

\copy temp_votacoes FROM './data/votacoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO votacoes
  SELECT * FROM temp_votacoes
  ON CONFLICT (id_votacao) 
  DO
    UPDATE
    SET 
      id_proposicao_voz = EXCLUDED.id_proposicao_voz,
      obj_votacao = EXCLUDED.obj_votacao,
      data_hora = EXCLUDED.data_hora,
      votacao_secreta = EXCLUDED.votacao_secreta,
      url_votacao = EXCLUDED.url_votacao;

DELETE FROM votacoes
 WHERE id_votacao NOT IN 
 (SELECT id_votacao FROM temp_votacoes);

DROP TABLE temp_votacoes;

COMMIT;