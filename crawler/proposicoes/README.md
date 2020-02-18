# Módulo Proposições

Este módulo é responsável por baixar, processar e retornar os dados referentes às proposições de autoria dos deputados e senadores nos anos de 2019 e 2020.

## Como exportar dados de proposições

Para gerar o csv de com informações de proposições é necessário usar o script `export_proposicoes.R`

Para isso execute:

```
Rscript export_proposicoes.R -o <output_filepath>
```

Argumentos do script:
- `-o`: Caminho e nome do arquivo de destino. Neste caso o caminho de saída default utilizado é `../../raw_data/proposicoes.csv`.

Após a execução do script o csv será gerado no caminho especificado.
