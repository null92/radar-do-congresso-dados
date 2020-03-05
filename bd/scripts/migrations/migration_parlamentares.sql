-- PARLAMENTARES
BEGIN;

CREATE TEMP TABLE temp_parlamentares AS SELECT * FROM parlamentares LIMIT 0;

\copy temp_parlamentares FROM './data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO parlamentares
SELECT *
FROM temp_parlamentares
ON CONFLICT (id_parlamentar_voz)
DO
  UPDATE
  SET 
    cpf = EXCLUDED.cpf,
    nome_civil = EXCLUDED.nome_civil,
    nome_eleitoral = EXCLUDED.nome_eleitoral,
    genero = EXCLUDED.genero,
    uf = EXCLUDED.uf,
    id_partido = EXCLUDED.id_partido,
    situacao = EXCLUDED.situacao,
    condicao_eleitoral = EXCLUDED.condicao_eleitoral,
    ultima_legislatura = EXCLUDED.ultima_legislatura,
    em_exercicio = EXCLUDED.em_exercicio,
    data_nascimento = EXCLUDED.data_nascimento,
    naturalidade = EXCLUDED.naturalidade,
    endereco = EXCLUDED.endereco,
    telefone = EXCLUDED.telefone,
    email = EXCLUDED.email;

DELETE FROM parlamentares
 WHERE id_parlamentar_voz NOT IN 
 (SELECT id_parlamentar_voz FROM temp_parlamentares);

DROP TABLE temp_parlamentares;

COMMIT;
