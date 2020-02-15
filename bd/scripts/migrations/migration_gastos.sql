-- GASTOS CEAP
BEGIN;

CREATE TEMP TABLE temp_gastos_ceap AS SELECT * FROM gastos_ceap LIMIT 0;

\copy temp_gastos_ceap FROM './data/gastos_ceap_congresso.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO gastos_ceap
SELECT *
FROM temp_gastos_ceap
ON CONFLICT (id)
DO
  UPDATE
  SET 
    id_parlamentar_voz = EXCLUDED.id_parlamentar_voz,
    casa = EXCLUDED.casa,
    ano = EXCLUDED.ano,
    mes = EXCLUDED.mes,
    documento = EXCLUDED.documento,
    descricao = EXCLUDED.descricao,
    especificacao = EXCLUDED.especificacao,
    data_emissao = EXCLUDED.data_emissao,
    fornecedor = EXCLUDED.fornecedor,
    cnpj_cpf_fornecedor = EXCLUDED.cnpj_cpf_fornecedor,
    valor_documento = EXCLUDED.valor_documento,
    valor_glosa = EXCLUDED.valor_glosa,
    valor_liquido = EXCLUDED.valor_liquido,
    num_parcela = EXCLUDED.num_parcela,
    valor_reembolsado = EXCLUDED.valor_reembolsado;

DELETE FROM gastos_ceap
 WHERE id NOT IN 
 (SELECT id FROM temp_gastos_ceap);

DROP TABLE temp_gastos_ceap;

COMMIT;