## Módulo de Patrimônio

Este módulo é responsável por baixar, processar e exportar dados de patrimônio declarado por deputados e senadores nas eleições em que os mesmos foram eleitos.

## Para baixar os dados

Os dados baixados do Repositório de Dados eleitoral do TSE ([link](http://www.tse.jus.br/eleicoes/estatisticas/repositorio-de-dados-eleitorais-1/repositorio-de-dados-eleitorais)) **já estão disponíveis** no repositório no diretório: `crawler/raw_data/dados_tse`.

Se você quiser baixar novamente os dados é possível usar o script `fetcher_patrimonio.sh`. 

```
./fetcher_patrimonio.sh
```

Certifique-se que você deu permissão de execução ao arquivo fazendo:

```
chmod +x fetcher_patrimonio.sh
```

## Para processar os dados

Os scripts `read_tse_data.R` e `analyzer_patrimonio.R` possuem funções que irão ler e padronizar os dados brutos disponibilizados pelo TSE e processá-los a fim de captura os bens declarados dos deputados e senadores que participaram da legislatura 56. Para os casos dos senadores eleitos em 2014, e que estão nos últimos 4 anos de seus mandatos de 8 anos, consideramos a declaração de bens dos mesmo em 2014. Para os demais parlamentares eleitos em 2018, a declaração de bens considerada foi a de 2018. Alguns parlamentares não declararam nenhum bem ao TSE.

## Para exportar os dados

Para exportar os dados use o script `export_patrimonio.R`

```
Rscript export_patrimonio.R -o <output_path>
```

Substitua <output_path> pelo caminho em que você deseja salvar os bens declarados pelos deputados e senadores da legislatura 56. O caminho default fica em `crawler/raw_data/patrimonio_parlamentares.csv`
