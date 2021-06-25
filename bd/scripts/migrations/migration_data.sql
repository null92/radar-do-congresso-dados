-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '06/25/2021'
WHERE
	id = 1;

COMMIT;