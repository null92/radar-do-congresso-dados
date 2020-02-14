\copy partidos FROM '/data/partidos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy parlamentares FROM '/data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;