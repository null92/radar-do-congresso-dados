-- data

BEGIN;

CREATE TEMP TABLE temp_data AS SELECT * FROM data LIMIT 0;

\copy temp_data FROM './data/data.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;

INSERT INTO data
	SELECT * FROM temp_data;

DROP TABLE temp_data;

COMMIT;