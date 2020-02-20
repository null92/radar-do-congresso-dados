DELETE FROM gastos_ceap;

\copy gastos_ceap FROM './data/gastos_ceap_congresso.csv' WITH NULL AS 'NA' DELIMITER ',' CSV HEADER;
