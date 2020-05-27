## Geração da tabela Votações

Este módulo possui informações referentes às votações das proposições em plenário nesta legislatura.

Para gerar as tabelas **votações** e **proposições votadas**, execute o script que processa os dados das votações e proposições estando neste diretório:
  ```
    Rscript export_votacoes_e_proposicoes_votadas.R -o <output_folderpath> 
  ```
    Com os seguintes argumentos:
     * `-o <output_datapath>`: Caminho para a pasta destino onde os arquivos csv `proposicoes_votadas.csv` e `votacoes.csv` serão salvos. O caminho default é "../raw_data/".
