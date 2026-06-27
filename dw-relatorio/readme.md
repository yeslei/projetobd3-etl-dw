# Relatório de Cobertura Analítica do Data Warehouse (Olist)
## Diretrizes, Requisitos de Negócio e Capacidades Declarativas do Modelo Dimensional

Este documento serve como especificação técnica e de negócios para o futuro Data Warehouse (DW) da operação Olist. O objetivo é mapear, através das **perguntas de negócio fundamentais**, os cenários analíticos, métricas avançadas e cruzamentos multidimensionais suportados pela arquitetura desenvolvida (Constellation Schema baseado na metodologia de Ralph Kimball).

Abaixo estão descritas as perguntas que o DW é capaz de responder, estruturadas pelas principais perspectivas estratégicas da companhia.

---

## Pré-requisitos

Antes de carregar os dados para o Data Warehouse, é fundamental executar o processo de ETL para gerar os arquivos de dados tratados.

1.  Abra o notebook `notebooks/etl_olist.ipynb`.
2.  Execute todas as células para gerar os arquivos tratados na pasta `output/`.
---

## 1. Perspectiva de Inteligência de Clientes, Retenção e Ciclo de Vida (Customer Success & Growth)

O modelo dimensional consolida a jornada histórica do consumidor a partir da chave única real do cliente (`customer_unique_id`), desvinculando a análise de compras isoladas e permitindo o rastreamento longitudinal de comportamento.

* **Análise de Cohort e Retenção Temporal:** Qual é a taxa de recompra (*repurchase rate*) dos consumidores com base no mês e ano de sua primeira aquisição na plataforma, e quais são os padrões de fidelização que se estabelecem ao longo do tempo?
* **Mensuração do Customer Lifetime Value (LTV):** Qual é o valor financeiro total acumulado gerado por um único cliente ao longo de seu ciclo de vida ativo, e como a incidência de cupons e descontos via incentivos operacionais (`payment_type = 'voucher'`) afeta esse retorno?
* **Segmentação RFM Avançada:** Como os clientes se distribuem em quadrantes comportamentais de alta granularidade com base em índices ponderados de **Recência** (dias desde o último pedido), **Frequência** (quantidade de transações convertidas no período) e **Valor Monetário** (gasto total acumulado)?
* **Impacto de Experiências Negativas na Retenção:** Qual é a probabilidade estatística de evasão de clientes (*churn*) ou de extensão do intervalo de compra (*interpurchase time*) após o registro de uma avaliação severamente insatisfatória (`review_score` entre 1 e 2) no primeiro pedido?

---

## 2. Perspectiva Logística, Desempenho de SLAs e Supply Chain

Apoiado por uma tabela fato do tipo *Accumulating Snapshot* (`Fato_Logistica`), o DW unifica os marcos temporais do ciclo de atendimento do e-commerce, permitindo avaliar a eficiência de ponta a ponta e a responsabilidade por gargalos operacionais.

* **Auditoria de SLA de Postagem do Vendedor:** Qual é o percentual de cumprimento de prazos internos por parte dos parceiros comerciais, e qual é o volume de pedidos cuja data de entrega à transportadora (`order_delivered_carrier_date`) violou o limite contratual estabelecido (`shipping_limit_date`)?
* **Diagnóstico de Gargalos no Funil de Distribuição:** Ao decompor o tempo total de trâmite de pacotes em subetapas críticas (Aprovação, Separação/Postagem e Trânsito Rodoviário), qual ator gera a maior fricção no processo quando analisado regionalmente (por Estado ou Cidade)?
* **Elasticidade e Atrito do Valor de Frete:** Qual é a proporção financeira do frete em relação ao preço nominal do produto (`freight_value` / `price`), e em quais regiões geográficas o custo logístico atua como o principal fator de barreira econômica ou cancelamento?
* **Influência de Características Físicas no Desempenho de Entrega:** Como o peso (`product_weight_g`) e o volume cúbico derivado do produto (`product_length_cm` * `product_width_cm` * `product_height_cm`) se correlacionam com os índices de atraso real (`dias_atraso`) acumulados pelas empresas de logística?

---

## 3. Perspectiva de Saúde Financeira, Meios de Pagamento e Gestão de Risco

O isolamento do processo de arrecadação em uma tabela fato dedicada (`Fato_Pagamentos`) mitiga o risco de distorção de dados (*double-counting*) e viabiliza a auditoria fina do fluxo de caixa e das preferências de crédito.

* **Alavancagem de Ticket Médio por Parcelamento:** Qual é a elasticidade do valor do pedido em função do número de parcelas adotadas pelo comprador (`payment_installments`), e quais categorias de produtos dependem criticamente de concessão de crédito a longo prazo para tracionar vendas?
* **Análise de Perda de Receita por Cancelamento e Indisponibilidade:** Qual é o impacto financeiro bruto e líquido causado por transações que evoluem para status de interrupção (`canceled` ou `unavailable`), e qual é a correlação desse comportamento com janelas temporais de aprovação tardia (`order_approved_at`)?
* **Comportamento de Liquidação via Múltiplos Canais:** Qual é o volume financeiro e quantitativo de pedidos cuja engenharia financeira exigiu a combinação sequencial de diferentes métodos de pagamento (`payment_sequential` > 1), e qual a relevância de transações mistas (ex: Cartão de Crédito somado a Vouchers de Benefício)?

---

## 4. Perspectiva de Catálogo de Produtos e Inteligência de Mercado (Merchandising)

O cruzamento multidimensional conecta os atributos informacionais de cadastro dos produtos ao seu desempenho comercial real e à percepção de valor pelo consumidor final.

* **Otimização de Atributos de Cadastro (Catálogo Eletrônico):** Qual é o impacto que a riqueza de dados do anúncio — medida pelo tamanho do texto descritivo (`product_description_lenght`) e pela quantidade de recursos visuais fornecidos (`product_photos_qty`) — exerce sobre a taxa de conversão de vendas e os índices de devolução ou suporte?
* **Concentração de Receita e Concentração de Risco (Curva ABC):** Aplicando o Princípio de Pareto (80/20), qual é o grau de dependência da plataforma em relação a um grupo restrito de grandes parceiros comerciais (`seller_id`) ou nichos de mercado mercadológicos específicos?
* **Mapeamento de Desequilíbrio Geográfico B2B2C (Assimetria de Oferta):** Onde ocorrem os fluxos logísticos ineficientes caracterizados por praças de consumo (ex: Região Nordeste) que demandam produtos majoritariamente de polos de venda distantes (ex: Região Sudeste), sinalizando oportunidades para atração regional de fornecedores?

---

## 5. Matriz de Barramento do Data Warehouse (Bus Matrix)

A matriz abaixo detalha a arquitetura de dados conformada do ecossistema, demonstrando como as tabelas fato compartilham as mesmas dimensões para viabilizar relatórios cruzados (*Drill-Across*).

| Tabelas Fato \ Dimensões | Dim_Tempo | Dim_Cliente | Dim_Produto | Dim_Vendedor | Dim_Forma_Pagamento |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Fato_Vendas** | X (Compra) | X | X | X | |
| **Fato_Pagamentos** | X (Compra) | X | | | X |
| **Fato_Logistica** | X (Múltiplos Papéis) | X (Destino) | | X (Origem) | |
| **Fato_Satisfacao** | X (Avaliação) | X | X | X | |

---

## 6. Diferenciais Técnicos e Capacidades de Otimização Consultiva

Ao implementar este modelo dimensional baseado nas diretrizes de Kimball, o ambiente analítico passa a responder a esses cenários garantindo:

1.  **Alta Performance em Consultas Complexas:** Queries que realizam agregações temporais de larga escala prescindem de varreduras do tipo *Full Table Scan* em strings, operando exclusivamente via *Joins* indexados entre inteiros (`sk_tempo`).
2.  **Isolamento de Erros de Granularidade:** Consultas financeiras de receita total não sofrem distorções caso um pedido contenha múltiplos itens, uma vez que a contabilidade física (`Fato_Vendas`) e a liquidação monetária (`Fato_Pagamentos`) correm em trilhos paralelos e perfeitamente síncronos.
3.  **Suporte Nativo a Ferramentas de Self-Service BI:** Estruturas baseadas em Constelações de Fatos são facilmente interpretadas por motores DAX (Power BI), modelos tabulares (Analysis Services) ou visualizadores como Looker e Tableau, permitindo que analistas de negócios criem relatórios avançados arrastando campos, sem a necessidade de codificação SQL complexa no dia a dia.