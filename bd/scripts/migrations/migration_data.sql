-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '09/20/2021'
WHERE
	id = 1;

COMMIT;