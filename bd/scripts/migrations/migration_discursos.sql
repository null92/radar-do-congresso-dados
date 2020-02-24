DELETE FROM discursos;

\copy discursos FROM './data/discursos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
