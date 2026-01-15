--Camada RAW
-- Configurações iniciais
SET timezone = 'America/Sao_Paulo';

-- Extensões necessárias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- SCHEMA RAW 

CREATE SCHEMA IF NOT EXISTS raw;

-- Drop das tabelas se existirem
DROP TABLE IF EXISTS raw.tb_estatisticas CASCADE;
DROP TABLE IF EXISTS raw.tb_cartoes CASCADE;
DROP TABLE IF EXISTS raw.tb_gols CASCADE;
DROP TABLE IF EXISTS raw.tb_partidas CASCADE;

-- TABELA: PARTIDAS 

CREATE TABLE raw.tb_partidas (
    -- Identificador único
    id BIGINT PRIMARY KEY,
    
    -- Dados temporais
    rodata INTEGER,
    data DATE,
    hora TIME,
    
    -- Times
    mandante VARCHAR(100),
    visitante VARCHAR(100),
    
    -- Formações e técnicos
    formacao_mandante VARCHAR(10),
    formacao_visitante VARCHAR(10),
    tecnico_mandante VARCHAR(100),
    tecnico_visitante VARCHAR(100),
    
    -- Resultado
    vencedor VARCHAR(100),
    mandante_placar INTEGER,
    visitante_placar INTEGER,
    
    -- Localização
    arena VARCHAR(200),
    mandante_estado VARCHAR(2),
    visitante_estado VARCHAR(2)
);

-- TABELA: GOLS 

CREATE TABLE raw.tb_gols (
    -- Chave composta (não tem ID único no CSV)
    partida_id BIGINT NOT NULL,
    rodata INTEGER,
    clube VARCHAR(100),
    atleta VARCHAR(200),
    minuto VARCHAR(10),
    tipo_de_gol VARCHAR(50),
    
    -- Constraint
    CONSTRAINT fk_gols_partida FOREIGN KEY (partida_id) 
        REFERENCES raw.tb_partidas(id) ON DELETE CASCADE
);

-- TABELA: CARTÕES 

CREATE TABLE raw.tb_cartoes (
    -- Chave composta
    partida_id BIGINT NOT NULL,
    rodata INTEGER,
    clube VARCHAR(100),
    cartao VARCHAR(20),
    atleta VARCHAR(200),
    num_camisa VARCHAR(10),
    posicao VARCHAR(50),
    minuto VARCHAR(10),
    
    -- Constraint
    CONSTRAINT fk_cartoes_partida FOREIGN KEY (partida_id) 
        REFERENCES raw.tb_partidas(id) ON DELETE CASCADE
);

-- TABELA: ESTATÍSTICAS 

CREATE TABLE raw.tb_estatisticas (
    -- Chave composta (uma linha por time por partida)
    partida_id BIGINT NOT NULL,
    rodata INTEGER,
    clube VARCHAR(100),
    
    -- Estatísticas da partida
    chutes INTEGER,
    chutes_no_alvo INTEGER,
    posse_de_bola DECIMAL(5,2),
    passes INTEGER,
    precisao_passes DECIMAL(5,2),
    faltas INTEGER,
    cartao_amarelo INTEGER,
    cartao_vermelho INTEGER,
    impedimentos INTEGER,
    escanteios INTEGER,
    
    -- Constraint
    CONSTRAINT fk_estatisticas_partida FOREIGN KEY (partida_id) 
        REFERENCES raw.tb_partidas(id) ON DELETE CASCADE
);

-- ÍNDICES PARA PERFORMANCE 

-- Partidas
CREATE INDEX idx_partidas_data ON raw.tb_partidas(data);
CREATE INDEX idx_partidas_mandante ON raw.tb_partidas(mandante);
CREATE INDEX idx_partidas_visitante ON raw.tb_partidas(visitante);
CREATE INDEX idx_partidas_rodata ON raw.tb_partidas(rodata);

-- Gols
CREATE INDEX idx_gols_partida ON raw.tb_gols(partida_id);
CREATE INDEX idx_gols_clube ON raw.tb_gols(clube);
CREATE INDEX idx_gols_atleta ON raw.tb_gols(atleta);

-- Cartões
CREATE INDEX idx_cartoes_partida ON raw.tb_cartoes(partida_id);
CREATE INDEX idx_cartoes_clube ON raw.tb_cartoes(clube);
CREATE INDEX idx_cartoes_atleta ON raw.tb_cartoes(atleta);

-- Estatísticas
CREATE INDEX idx_estatisticas_partida ON raw.tb_estatisticas(partida_id);
CREATE INDEX idx_estatisticas_clube ON raw.tb_estatisticas(clube);

-- MENSAGEM DE SUCESSO 

DO $$
BEGIN
    RAISE NOTICE 'Schema RAW criado com sucesso!';
    RAISE NOTICE '   - Tabela raw.tb_partidas';
    RAISE NOTICE '   - Tabela raw.tb_gols';
    RAISE NOTICE '   - Tabela raw.tb_cartoes';
    RAISE NOTICE '   - Tabela raw.tb_estatisticas';
    RAISE NOTICE '   - Índices criados';
END $$;
