-- Arquitetura Medalhão: Camada SILVER
-- Configurações iniciais
SET timezone = 'America/Sao_Paulo';

CREATE SCHEMA IF NOT EXISTS silver;

-- Drop da tabela se existir
DROP TABLE IF EXISTS silver.tb_partidas_completa CASCADE;

-- Esta tabela integra TODOS os dados das 4 tabelas RAW (CSV) em uma única estrutura

CREATE TABLE silver.tb_partidas_completa (
    
    --IDENTIFICADORES 
    partida_id BIGINT NOT NULL,
    
    --DADOS TEMPORAIS 
    rodata INTEGER,
    data DATE,
    hora TIME,
    data_hora TIMESTAMP,
    ano INTEGER,
    mes INTEGER,
    dia_semana VARCHAR(20),
    
    -- DADOS DOS TIMES 
    -- Mandante
    mandante VARCHAR(100),
    mandante_estado VARCHAR(2),
    mandante_placar INTEGER,
    
    -- Visitante
    visitante VARCHAR(100),
    visitante_estado VARCHAR(2),
    visitante_placar INTEGER,
    
    --  RESULTADO DA PARTIDA 
    vencedor VARCHAR(100),
    tipo_resultado VARCHAR(20), -- 'Vitória Mandante', 'Vitória Visitante', 'Empate'
    diferenca_gols INTEGER,
    total_gols INTEGER,
    
    --  LOCALIZAÇÃO 
    arena VARCHAR(200),
    estado_partida VARCHAR(2),
    
    --  ESTATÍSTICAS - MANDANTE 
    mandante_chutes INTEGER,
    mandante_chutes_alvo INTEGER,
    mandante_posse_bola DECIMAL(5,2),
    mandante_passes INTEGER,
    mandante_precisao_passes DECIMAL(5,2),
    mandante_faltas INTEGER,
    mandante_cartoes_amarelos INTEGER,
    mandante_cartoes_vermelhos INTEGER,
    mandante_impedimentos INTEGER,
    mandante_escanteios INTEGER,
    
    --  ESTATÍSTICAS - VISITANTE 
    visitante_chutes INTEGER,
    visitante_chutes_alvo INTEGER,
    visitante_posse_bola DECIMAL(5,2),
    visitante_passes INTEGER,
    visitante_precisao_passes DECIMAL(5,2),
    visitante_faltas INTEGER,
    visitante_cartoes_amarelos INTEGER,
    visitante_cartoes_vermelhos INTEGER,
    visitante_impedimentos INTEGER,
    visitante_escanteios INTEGER,
    
    --  TOTALIZADORES DE GOLS 
    total_gols_mandante INTEGER DEFAULT 0,
    total_gols_visitante INTEGER DEFAULT 0,
    total_gols_partida INTEGER DEFAULT 0,
    gols_contra INTEGER DEFAULT 0,
    gols_penalty INTEGER DEFAULT 0,
    
    --  TOTALIZADORES DE CARTÕES 
    total_cartoes_amarelos INTEGER DEFAULT 0,
    total_cartoes_vermelhos INTEGER DEFAULT 0,
    total_cartoes INTEGER DEFAULT 0,
    
    --  CLASSIFICAÇÕES CALCULADAS 
    foi_equilibrado BOOLEAN, -- Diferença <= 1 gol
    foi_goleada BOOLEAN, -- Diferença >= 3 gols
    teve_virada BOOLEAN, -- Analisar sequência de gols
    categoria_gols VARCHAR(20) -- 'Sem gols', 'Poucos gols', 'Muitos gols', 'Jogo de gols'
);

--ÍNDICES PARA PERFORMANCE 

CREATE INDEX idx_silver_partida ON silver.tb_partidas_completa(partida_id);
CREATE INDEX idx_silver_data ON silver.tb_partidas_completa(data);
CREATE INDEX idx_silver_ano ON silver.tb_partidas_completa(ano);
CREATE INDEX idx_silver_rodata ON silver.tb_partidas_completa(rodata);
CREATE INDEX idx_silver_mandante ON silver.tb_partidas_completa(mandante);
CREATE INDEX idx_silver_visitante ON silver.tb_partidas_completa(visitante);
CREATE INDEX idx_silver_vencedor ON silver.tb_partidas_completa(vencedor);
CREATE INDEX idx_silver_arena ON silver.tb_partidas_completa(arena);

-- MENSAGEM DE SUCESSO 

DO $$
BEGIN
    RAISE NOTICE 'Schema SILVER criado com sucesso!';
    RAISE NOTICE '   - Tabela silver.tb_partidas_completa';
    RAISE NOTICE '   - Índices criados';
    RAISE NOTICE '';
    RAISE NOTICE 'PRÓXIMO PASSO: Executar ETL para popular a tabela silver';
END $$;
