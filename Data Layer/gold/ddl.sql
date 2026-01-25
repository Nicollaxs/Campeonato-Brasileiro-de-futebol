-- Consultas Analiticas - Camada GOLD
-- 10 Consultas Principais para Analise do Campeonato Brasileiro

-- 1. Top 10 Times com Melhor Aproveitamento Historico
SELECT 
    ds_tim_nom,
    ds_tim_est,
    COUNT(DISTINCT nr_tem_ano) as temporadas_disputadas,
    SUM(total_jogos) as total_jogos,
    SUM(total_pontos) as total_pontos,
    ROUND(AVG(aproveitamento_pct), 2) as aproveitamento_medio,
    SUM(gols_marcados) as gols_marcados,
    SUM(gols_sofridos) as gols_sofridos,
    SUM(saldo_gols) as saldo_gols
FROM gold.vw_ranking_times
WHERE total_jogos >= 10
GROUP BY ds_tim_nom, ds_tim_est
ORDER BY aproveitamento_medio DESC, total_pontos DESC
LIMIT 10;

-- 2. Desempenho Mandante vs Visitante (Ultimos 5 Anos)
WITH stats_mandante AS (
    SELECT 
        t.ds_tim_nom,
        COUNT(*) as jogos_casa,
        SUM(CASE WHEN r.ds_res_ven = t.ds_tim_nom THEN 1 ELSE 0 END) as vitorias_casa,
        ROUND(AVG(fp.vl_par_man_pos_bol), 2) as posse_media_casa
    FROM gold.fct_par_partida fp
    JOIN gold.dim_tim_time t ON fp.srk_tim_man = t.srk_tim_tim
    JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
    LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
    WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM gold.dim_tem_tempo)
    GROUP BY t.ds_tim_nom
),
stats_visitante AS (
    SELECT 
        t.ds_tim_nom,
        COUNT(*) as jogos_fora,
        SUM(CASE WHEN r.ds_res_ven = t.ds_tim_nom THEN 1 ELSE 0 END) as vitorias_fora,
        ROUND(AVG(fp.vl_par_vis_pos_bol), 2) as posse_media_fora
    FROM gold.fct_par_partida fp
    JOIN gold.dim_tim_time t ON fp.srk_tim_vis = t.srk_tim_tim
    JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
    LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
    WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM gold.dim_tem_tempo)
    GROUP BY t.ds_tim_nom
)
SELECT 
    sm.ds_tim_nom,
    sm.jogos_casa,
    sm.vitorias_casa,
    ROUND(sm.vitorias_casa::NUMERIC / sm.jogos_casa * 100, 2) as taxa_vitoria_casa,
    sv.jogos_fora,
    sv.vitorias_fora,
    ROUND(sv.vitorias_fora::NUMERIC / sv.jogos_fora * 100, 2) as taxa_vitoria_fora
FROM stats_mandante sm
JOIN stats_visitante sv ON sm.ds_tim_nom = sv.ds_tim_nom
WHERE sm.jogos_casa >= 10 AND sv.jogos_fora >= 10
ORDER BY taxa_vitoria_casa DESC
LIMIT 15;

-- 3. Evolucao de Gols por Ano
SELECT 
    dt.nr_tem_ano,
    COUNT(*) as total_partidas,
    SUM(fp.qt_par_tot_gol) as total_gols,
    ROUND(AVG(fp.qt_par_tot_gol), 2) as media_gols_partida,
    SUM(CASE WHEN r.fl_res_gol THEN 1 ELSE 0 END) as total_goleadas,
    ROUND(SUM(CASE WHEN r.fl_res_gol THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) as pct_goleadas
FROM gold.fct_par_partida fp
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
GROUP BY dt.nr_tem_ano
ORDER BY dt.nr_tem_ano;

-- 4. Analise por Dia da Semana
SELECT 
    dt.ds_tem_dia_sem,
    dt.fl_tem_fim_sem,
    COUNT(*) as total_partidas,
    ROUND(AVG(fp.qt_par_tot_gol), 2) as media_gols,
    SUM(CASE WHEN r.ds_res_tip_res = 'Vitoria Mandante' THEN 1 ELSE 0 END) as vitorias_mandante,
    SUM(CASE WHEN r.ds_res_tip_res = 'Empate' THEN 1 ELSE 0 END) as empates,
    ROUND(SUM(CASE WHEN r.ds_res_tip_res = 'Vitoria Mandante' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) as pct_vitorias_mandante
FROM gold.fct_par_partida fp
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
GROUP BY dt.ds_tem_dia_sem, dt.fl_tem_fim_sem, dt.nr_tem_dia_sem
ORDER BY dt.nr_tem_dia_sem;

-- 5. Top 10 Arenas com Maior Media de Gols
SELECT 
    da.ds_are_nom,
    da.ds_are_est,
    da.ds_are_reg,
    COUNT(*) as total_partidas,
    ROUND(AVG(fp.qt_par_tot_gol), 2) as media_gols,
    SUM(fp.qt_par_tot_gol) as total_gols,
    ROUND(SUM(CASE WHEN r.ds_res_tip_res = 'Vitoria Mandante' THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) as pct_vitorias_mandante
FROM gold.fct_par_partida fp
JOIN gold.dim_are_arena da ON fp.srk_are_are = da.srk_are_are
LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
GROUP BY da.ds_are_nom, da.ds_are_est, da.ds_are_reg
HAVING COUNT(*) >= 20
ORDER BY media_gols DESC
LIMIT 10;

-- 6. Times Mais Eficientes na Finalizacao (Ultimos 5 Anos)
SELECT 
    t.ds_tim_nom,
    COUNT(*) as jogos,
    ROUND(AVG(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.vl_par_man_tax_con
            ELSE fp.vl_par_vis_tax_con
        END
    ), 2) as taxa_conversao_media,
    ROUND(AVG(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.vl_par_man_efi
            ELSE fp.vl_par_vis_efi
        END
    ), 2) as eficiencia_media,
    SUM(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.qt_par_gol_man
            ELSE fp.qt_par_gol_vis
        END
    ) as total_gols
FROM gold.fct_par_partida fp
JOIN gold.dim_tim_time t ON (fp.srk_tim_man = t.srk_tim_tim OR fp.srk_tim_vis = t.srk_tim_tim)
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM gold.dim_tem_tempo)
GROUP BY t.ds_tim_nom
HAVING COUNT(*) >= 30
ORDER BY taxa_conversao_media DESC
LIMIT 10;

-- 7. Times Mais Disciplinados (Ultimos 5 Anos)
SELECT 
    t.ds_tim_nom,
    COUNT(*) as jogos,
    SUM(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.qt_par_man_car_ama
            ELSE fp.qt_par_vis_car_ama
        END
    ) as total_amarelos,
    SUM(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.qt_par_man_car_ver
            ELSE fp.qt_par_vis_car_ver
        END
    ) as total_vermelhos,
    ROUND(AVG(
        CASE 
            WHEN fp.srk_tim_man = t.srk_tim_tim THEN fp.qt_par_man_car_ama + fp.qt_par_man_car_ver
            ELSE fp.qt_par_vis_car_ama + fp.qt_par_vis_car_ver
        END
    ), 2) as media_cartoes_jogo
FROM gold.fct_par_partida fp
JOIN gold.dim_tim_time t ON (fp.srk_tim_man = t.srk_tim_tim OR fp.srk_tim_vis = t.srk_tim_tim)
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM gold.dim_tem_tempo)
GROUP BY t.ds_tim_nom
HAVING COUNT(*) >= 30
ORDER BY media_cartoes_jogo ASC
LIMIT 10;

-- 8. Maiores Goleadas da Historia
SELECT 
    dt.dt_tem_dat,
    dt.nr_tem_ano,
    tm.ds_tim_nom as mandante,
    tv.ds_tim_nom as visitante,
    fp.qt_par_gol_man,
    fp.qt_par_gol_vis,
    fp.qt_par_dif_gol,
    r.ds_res_ven as vencedor,
    da.ds_are_nom as arena
FROM gold.fct_par_partida fp
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
JOIN gold.dim_tim_time tm ON fp.srk_tim_man = tm.srk_tim_tim
JOIN gold.dim_tim_time tv ON fp.srk_tim_vis = tv.srk_tim_tim
LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
JOIN gold.dim_are_arena da ON fp.srk_are_are = da.srk_are_are
WHERE r.fl_res_gol = TRUE
ORDER BY fp.qt_par_dif_gol DESC, fp.qt_par_tot_gol DESC
LIMIT 20;

-- 9. Dashboard Executivo - Metricas Consolidadas
SELECT 
    COUNT(DISTINCT dt.nr_tem_ano) as temporadas,
    COUNT(DISTINCT t.srk_tim_tim) as times_diferentes,
    COUNT(DISTINCT da.srk_are_are) as arenas_utilizadas,
    COUNT(*) as total_partidas,
    SUM(fp.qt_par_tot_gol) as total_gols,
    ROUND(AVG(fp.qt_par_tot_gol), 2) as media_gols_partida,
    ROUND(AVG(fp.vl_par_man_pos_bol), 2) as posse_media_mandante,
    ROUND(AVG(fp.vl_par_vis_pos_bol), 2) as posse_media_visitante,
    SUM(fp.qt_par_tot_car_ama) as total_amarelos,
    SUM(fp.qt_par_tot_car_ver) as total_vermelhos,
    SUM(CASE WHEN r.ds_res_tip_res = 'Vitoria Mandante' THEN 1 ELSE 0 END) as vitorias_mandante,
    SUM(CASE WHEN r.ds_res_tip_res = 'Empate' THEN 1 ELSE 0 END) as empates,
    SUM(CASE WHEN r.ds_res_tip_res = 'Vitoria Visitante' THEN 1 ELSE 0 END) as vitorias_visitante
FROM gold.fct_par_partida fp
JOIN gold.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
JOIN gold.dim_tim_time t ON (fp.srk_tim_man = t.srk_tim_tim OR fp.srk_tim_vis = t.srk_tim_tim)
JOIN gold.dim_are_arena da ON fp.srk_are_are = da.srk_are_are
LEFT JOIN gold.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res;

-- 10. Ranking Ultima Temporada Completa
SELECT 
    ROW_NUMBER() OVER (ORDER BY total_pontos DESC, saldo_gols DESC) as posicao,
    ds_tim_nom,
    ds_tim_est,
    total_jogos,
    total_pontos,
    gols_marcados,
    gols_sofridos,
    saldo_gols,
    aproveitamento_pct
FROM gold.vw_ranking_times
WHERE nr_tem_ano = (SELECT MAX(nr_tem_ano) FROM gold.dim_tem_tempo)
ORDER BY total_pontos DESC, saldo_gols DESC
LIMIT 20;
