-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '03/15/2021'
WHERE
	id = 1;

COMMIT;