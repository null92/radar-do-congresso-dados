BEGIN;

DELETE FROM patrimonio;

\copy patrimonio FROM './data/patrimonio.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

COMMIT;
