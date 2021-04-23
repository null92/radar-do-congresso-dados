-- data

BEGIN;

UPDATE
	data_atualizacao
SET
	data_atualizacao = '04/23/2021'
WHERE
	id = 1;

COMMIT;