# Projeto BD3 - ETL com Dataset Olist

Este projeto tem como objetivo desenvolver a primeira etapa de um fluxo de Engenharia de Dados usando os arquivos CSV da pasta `dataset`. Nesta fase, o foco e apenas o processo de ETL: extrair os dados brutos, tratar problemas de qualidade, padronizar campos, criar atributos derivados e gerar arquivos tratados para uso futuro.

> Observacao: a modelagem em tabelas fato e dimensoes ainda nao sera implementada nesta etapa. Ela fica como uma proxima fase do projeto.

## Tema do Projeto

O dataset utilizado representa uma operacao de e-commerce, baseada no conjunto publico da Olist. Ele contem informacoes sobre clientes, pedidos, itens vendidos, produtos, vendedores, pagamentos, avaliacoes e geolocalizacao.

A proposta e simular uma rotina real de preparacao de dados para apoiar analises gerenciais, como desempenho de vendas, prazos de entrega, avaliacao de clientes, categorias mais vendidas e comportamento regional dos pedidos.

## Objetivo Geral

Construir um notebook Jupyter com um processo ETL completo para transformar os CSVs brutos da pasta `dataset` em dados tratados, consistentes e prontos para etapas posteriores de analise, Data Mart ou dashboards.

## Objetivos Especificos

- Ler todos os arquivos CSV brutos do dataset.
- Verificar estrutura, volume, tipos de dados e valores ausentes.
- Padronizar textos, datas, UFs, CEPs e nomes de colunas.
- Remover duplicidades.
- Tratar valores ausentes conforme o significado de cada tabela.
- Corrigir inconsistencias basicas em valores numericos, datas e campos categoricos.
- Criar atributos derivados uteis para analise.
- Integrar as principais tabelas em um CSV tratado de pedidos com itens.
- Gerar arquivos tratados na pasta `output`.
- Documentar o fluxo para facilitar reproducao e apresentacao.

## Dataset

Os arquivos esperados ficam na pasta `dataset`:

- `olist_customers_dataset.csv`: dados dos clientes.
- `olist_geolocation_dataset.csv`: latitude, longitude, cidade e UF por prefixo de CEP.
- `olist_orders_dataset.csv`: pedidos e datas do ciclo de entrega.
- `olist_order_items_dataset.csv`: itens de cada pedido, produto, vendedor, preco e frete.
- `olist_order_payments_dataset.csv`: pagamentos dos pedidos.
- `olist_order_reviews_dataset.csv`: avaliacoes dos clientes.
- `olist_products_dataset.csv`: produtos, categorias e medidas fisicas.
- `olist_sellers_dataset.csv`: vendedores.
- `product_category_name_translation.csv`: traducao das categorias de produto.

## Estrutura do Projeto

```text
projetobd3-etl-dw/
├── dataset/
│   ├── olist_customers_dataset.csv
│   ├── olist_geolocation_dataset.csv
│   ├── olist_orders_dataset.csv
│   ├── olist_order_items_dataset.csv
│   ├── olist_order_payments_dataset.csv
│   ├── olist_order_reviews_dataset.csv
│   ├── olist_products_dataset.csv
│   ├── olist_sellers_dataset.csv
│   └── product_category_name_translation.csv
├── notebooks/
│   └── etl_olist.ipynb
├── output/
│   └── arquivos gerados pelo notebook
└── README.md
```

## Notebook Principal

O notebook principal esta em:

```text
notebooks/etl_olist.ipynb
```

Ele esta dividido nas seguintes etapas:

1. Configuracao do ambiente e importacao de bibliotecas.
2. Definicao dos caminhos de entrada e saida.
3. Leitura dos CSVs brutos.
4. Perfilamento inicial dos dados.
5. Padronizacao de textos, UFs e CEPs.
6. Conversao de datas e campos numericos.
7. Tratamento de nulos e duplicados.
8. Criacao de atributos derivados.
9. Agregacao de pagamentos, avaliacoes e geolocalizacao.
10. Integracao das tabelas em uma base tratada de pedidos com itens.
11. Validacoes finais de qualidade.
12. Gravacao dos CSVs tratados na pasta `output`.

## Regras de Tratamento Aplicadas

### Padronizacao de textos

- Remocao de espacos no inicio e no fim.
- Conversao para letras minusculas em cidades e categorias.
- Normalizacao de acentos para facilitar comparacoes.
- Padronizacao das UFs em letras maiusculas.

### CEPs

- Prefixos de CEP sao convertidos para texto.
- Valores sao preenchidos com zeros a esquerda ate 5 caracteres.

### Datas

- Campos de data sao convertidos para `datetime`.
- Datas invalidas sao transformadas em valores nulos.
- Sao criados atributos como ano, mes, trimestre, dia da semana e dias ate entrega.

### Valores ausentes

- Categorias de produto ausentes recebem `sem_categoria`.
- Comentarios de avaliacoes ausentes recebem texto vazio.
- Medidas numericas de produtos ausentes sao preenchidas com mediana.
- Campos agregados inexistentes apos joins recebem valores padrao.

### Duplicidades

- Registros duplicados sao removidos em todas as tabelas.
- Para geolocalizacao, os registros sao agregados por prefixo de CEP para evitar multiplas coordenadas para o mesmo prefixo.

### Inconsistencias

- UFs fora da lista oficial brasileira sao marcadas como ausentes.
- Precos, fretes, pagamentos e medidas fisicas negativos sao tratados como nulos ou zero conforme o contexto.
- O atraso de entrega e calculado comparando entrega real com data estimada.

## Atributos Derivados

O ETL cria campos novos para facilitar analises:

- `ano_pedido`
- `mes_pedido`
- `trimestre_pedido`
- `dia_semana_pedido`
- `dias_entrega`
- `dias_estimados_entrega`
- `atraso_dias`
- `entregue_no_prazo`
- `valor_total_item`
- `valor_total_pagamento`
- `quantidade_formas_pagamento`
- `review_score_medio`
- `tem_comentario`

## Saidas Geradas

Ao executar o notebook, a pasta `output` sera criada automaticamente com arquivos como:

- `customers_tratado.csv`
- `orders_tratado.csv`
- `order_items_tratado.csv`
- `products_tratado.csv`
- `sellers_tratado.csv`
- `payments_agregado.csv`
- `reviews_agregado.csv`
- `geolocation_agregado.csv`
- `pedidos_itens_tratado.csv`
- `relatorio_qualidade_etl.csv`

O arquivo mais importante desta etapa e:

```text
output/pedidos_itens_tratado.csv
```

Ele concentra pedidos, clientes, itens, produtos, vendedores, pagamentos, avaliacoes e informacoes geograficas em uma unica base tratada.

## Como Executar

1. Abra o projeto no VS Code, Jupyter Notebook, JupyterLab ou Anaconda.
2. Instale as dependencias necessarias, se ainda nao existirem:

```bash
pip install pandas numpy
```

3. Abra o notebook:

```text
notebooks/etl_olist.ipynb
```

4. Execute as celulas em ordem.
5. Verifique os arquivos gerados na pasta `output`.

## Consultas Analiticas Possiveis Depois do ETL

Mesmo sem criar fatos e dimensoes nesta etapa, os dados tratados ja permitem algumas analises:

- Faturamento por mes.
- Volume de pedidos por estado e cidade.
- Categorias de produtos mais vendidas.
- Ticket medio por pedido.
- Vendedores com maior volume de vendas.
- Prazo medio de entrega.
- Pedidos entregues com atraso.
- Media de avaliacao por categoria.
- Relacao entre atraso de entrega e nota da avaliacao.
- Formas de pagamento mais utilizadas.

## Proximas Etapas do Projeto

As proximas fases podem incluir:

- Modelagem de Data Mart.
- Criacao de tabela fato de vendas ou pedidos.
- Criacao de dimensoes como cliente, produto, vendedor, tempo e localidade.
- Carga em banco relacional.
- Consultas SQL analiticas.
- Dashboard em Power BI, Tableau, Looker Studio ou Streamlit.
- Documentacao final com arquitetura do pipeline.

## Divisao Sugerida para o Grupo

1. Integrante 1: entendimento do dataset, dicionario de dados e perfilamento inicial.
2. Integrante 2: implementacao do ETL no notebook.
3. Integrante 3: validacoes de qualidade, tratamento de inconsistencias e geracao dos CSVs tratados.
4. Integrante 4: README, documentacao, analises exploratorias e preparacao da apresentacao.

## Status Atual

- Dataset bruto disponivel em `dataset`.
- Notebook ETL criado em `notebooks/etl_olist.ipynb`.
- README documentando proposta, fluxo, regras e proximas etapas.
- Data Mart ainda nao implementado nesta fase.
