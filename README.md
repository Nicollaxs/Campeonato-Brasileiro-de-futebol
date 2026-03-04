# Campeonato Brasileiro de Futebol — Pipeline de Dados

Este repositório contém o pipeline e os artefatos de dados utilizados para processar, transformar e disponibilizar informações do Campeonato Brasileiro de Futebol. O projeto segue a arquitetura Raw → Silver → Gold, com notebooks e artefatos SQL para definição de modelos e consultas analíticas.

## Visão geral

Objetivos principais:

- Organizar e padronizar os dados de partidas, gols, cartões e estatísticas do Campeonato Brasileiro.
- Implementar um pipeline ETL reproducível que transforme dados brutos (CSV) em tabelas tratadas e prontas para análise/BI (Silver/Gold).
- Fornecer queries e DDL que sustentem análises, dashboards e indicadores.

Público-alvo: engenheiros de dados, analistas e cientistas de dados que vão operar e consumir o dataset.

## Estrutura do repositório

Raiz

- `Dockerfile`, `docker-compose.yml` — configuração opcional para execução em container.
- `requirements.txt` — dependências Python usadas nos notebooks e scripts.

Diretórios principais

- `Data Layer/`
  - `raw/` — arquivos CSV originais e notebooks de exploração (`analytics.ipynb`). Arquivos presentes:
    - `campeonato-brasileiro-full.csv`
    - `campeonato-brasileiro-gols.csv`
    - `campeonato-brasileiro-cartoes.csv`
    - `campeonato-brasileiro-estatisticas-full.csv`
  - `silver/` — artefatos transformados (ex.: `tb_partidas_completa.csv`) e `ddl.sql` para esquema intermediário.
  - `gold/` — DDL final e `consultas.sql` com queries analíticas prontas para consumo.

- `Transformer/` — notebooks de transformação:
  - `etl_raw_to_silver_.ipynb` — limpeza e harmonização dos CSVs brutos para produzir a camada Silver.
  - `etl_silver_to_gold.ipynb` — enriquecimento, agregações e geração das tabelas Gold.

## Pipeline ETL (resumo)

1. Coleta: dados brutos originam-se de CSVs na pasta `Data Layer/raw/`.
2. Ingestão e limpeza (Raw → Silver): renomeação de colunas, normalização de tipos (datas, numéricos), tratamento de valores faltantes e deduplicação. Resultados persistidos em `Data Layer/silver/`.
3. Enriquecimento e modelagem (Silver → Gold): cálculos de métricas por partida, tabelas dimensionais (times, estádios) e tabelas fato otimizadas para análise. DDL e consultas finais ficam em `Data Layer/gold/`.

Os notebooks em `Transformer/` apresentam o código e as transformações aplicadas (pode-se convertê-los para scripts para produção se necessário).

## Principais artefatos

- `Data Layer/gold/ddl.sql` — scripts de criação das tabelas finais.
- `Data Layer/gold/consultas.sql` — exemplos de consultas analíticas (ex.: desempenho por time, soma de gols, cartões, médias por rodada).
- `Data Layer/silver/tb_partidas_completa.csv` — tabela consolidada de partidas na camada Silver.

## Como executar (local)

Pré-requisitos:

- Python 3.8+ e `pip`
- Recomenda-se criar um ambiente virtual

Exemplo (Fish shell):

```fish
python -m venv .venv
source .venv/bin/activate.fish
pip install --upgrade pip
pip install -r requirements.txt
```

Para abrir os notebooks:

```fish
jupyter lab
```

Observação: os notebooks documentam as transformações; para execução automatizada em CI/produção recomenda-se transformar os notebooks em scripts Python ou usar ferramentas como Papermill para parametrização.

## Como executar com Docker (opcional)

Se houver interesse em execução isolada via container, use o `docker-compose` (se o projeto fornecer imagem/serviços):

```fish
docker compose build
docker compose up -d
```

A configuração de container varia conforme como você desejar empacotar Jupyter, dependências e volumes de dados.



## Contato

Para dúvidas sobre o pipeline ou integração de dados, entre em contato.
---
