-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '09/06/2021'
WHERE
	id = 1;

COMMIT;