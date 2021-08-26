-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '08/25/2021'
WHERE
	id = 1;

COMMIT;