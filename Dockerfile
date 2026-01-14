# Imagem base do PostgreSQL
FROM postgres:15-alpine

# Informações do maintainer
LABEL maintainer="Campeonato Brasileiro"
LABEL description="Banco de dados PostgreSQL para análise do Brasileirão"

# Variáveis de ambiente padrão
ENV POSTGRES_DB=brasileirao
ENV POSTGRES_USER=brasileirao_user
ENV POSTGRES_PASSWORD=brasileirao_pass

# Copiar scripts DDL para o diretório de init do PostgreSQL
COPY "Data Layer/raw/ddl.sql" /docker-entrypoint-initdb.d/00_raw_ddl.sql
COPY "Data Layer/silver/ddl.sql" /docker-entrypoint-initdb.d/01_silver_ddl.sql
COPY "Data Layer/gold/ddl.sql" /docker-entrypoint-initdb.d/02_gold_ddl.sql

# Expor porta padrão do PostgreSQL
EXPOSE 5432
