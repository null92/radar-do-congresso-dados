\copy partidos FROM '/data/partidos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy parlamentares FROM '/data/parlamentares.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy gastos_ceap FROM '/data/gastos_ceap_congresso.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy proposicoes FROM '/data/proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy parlamentares_proposicoes FROM '/data/parlamentares_proposicoes.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy patrimonio FROM './data/patrimonio.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
\copy discursos FROM '/data/discursos.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
