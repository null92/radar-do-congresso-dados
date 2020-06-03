# Módulo Gastos de CEAP

A Cota para o Exercício da Atividade Parlamentar – CEAP (antiga verba indenizatória) é uma cota única mensal destinada a custear os gastos dos deputados exclusivamente vinculados ao exercício da atividade parlamentar (Mais detalhes [aqui]("https://www2.camara.leg.br/transparencia/acesso-a-informacao/copy_of_perguntas-frequentes/cota-para-o-exercicio-da-atividade-parlamentar")).

## Como exportar dados de gastos de CEAP

Para gerar o csv de com informações de parlamentares é necessário usar o script `export_gastos_ceap.R`

Para isso execute:

```
Rscript export_gastos_ceap.R -a <ano> -o <output_filepath>
```

Argumentos do script:
- `-a`: Ano de interesse. O valor default é 2019 e 2020;
- `-o`: Caminho e nome do arquivo de destino. Neste caso o caminho de saída default utilizado é `../../raw_data/gastos_ceap_congresso.csv`.

Após a execução do script o csv será gerado no caminho especificado.
