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
FROM dw.vw_ranking_times
WHERE total_jogos >= 38 -- Filtro para evitar times com poucos jogos distorcendo a média
GROUP BY ds_tim_nom, ds_tim_est
ORDER BY aproveitamento_medio DESC, total_pontos DESC
LIMIT 10;

-- 2. Desempenho Mandante vs Visitante (Ultimos 5 Anos)
WITH stats_mandante AS (
    SELECT 
        t.ds_tim_nom,
        COUNT(*) as jogos_casa,
        SUM(CASE WHEN r.ds_res_ven = t.ds_tim_nom THEN 1 ELSE 0 END) as vitorias_casa
    FROM dw.fct_par_partida fp
    JOIN dw.dim_tim_time t ON fp.srk_tim_mandante = t.srk_tim_tim
    JOIN dw.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
    LEFT JOIN dw.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
    WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM dw.dim_tem_tempo)
    GROUP BY t.ds_tim_nom
),
stats_visitante AS (
    SELECT 
        t.ds_tim_nom,
        COUNT(*) as jogos_fora,
        SUM(CASE WHEN r.ds_res_ven = t.ds_tim_nom THEN 1 ELSE 0 END) as vitorias_fora
    FROM dw.fct_par_partida fp
    JOIN dw.dim_tim_time t ON fp.srk_tim_visitante = t.srk_tim_tim
    JOIN dw.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
    LEFT JOIN dw.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
    WHERE dt.nr_tem_ano >= (SELECT MAX(nr_tem_ano) - 4 FROM dw.dim_tem_tempo)
    GROUP BY t.ds_tim_nom
)
SELECT 
    sm.ds_tim_nom,
    sm.jogos_casa,
    sm.vitorias_casa,
    ROUND(sm.vitorias_casa::NUMERIC / NULLIF(sm.jogos_casa, 0) * 100, 2) as taxa_vitoria_casa,
    sv.jogos_fora,
    sv.vitorias_fora,
    ROUND(sv.vitorias_fora::NUMERIC / NULLIF(sv.jogos_fora, 0) * 100, 2) as taxa_vitoria_fora
FROM stats_mandante sm
JOIN stats_visitante sv ON sm.ds_tim_nom = sv.ds_tim_nom
WHERE sm.jogos_casa >= 19 -- Pelo menos uma temporada em casa
ORDER BY taxa_vitoria_casa DESC
LIMIT 15;

-- 3. Evolucao de Gols por Ano
SELECT 
    dt.nr_tem_ano,
    COUNT(*) as total_partidas,
    SUM(fp.vl_par_tot_gol) as total_gols,
    ROUND(AVG(fp.vl_par_tot_gol), 2) as media_gols_partida,
    SUM(CASE WHEN r.fl_res_gol THEN 1 ELSE 0 END) as total_goleadas,
    ROUND(SUM(CASE WHEN r.fl_res_gol THEN 1 ELSE 0 END)::NUMERIC / COUNT(*) * 100, 2) as pct_goleadas
FROM dw.fct_par_partida fp
JOIN dw.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
LEFT JOIN dw.dim_res_resultado r ON fp.srk_res_res = r.srk_res_res
GROUP BY dt.nr_tem_ano
ORDER BY dt.nr_tem_ano;

-- 5. Top 10 Arenas com Maior Media de Gols
SELECT 
    da.ds_are_nom,
    da.ds_are_est,
    COUNT(*) as total_partidas,
    ROUND(AVG(fp.vl_par_tot_gol), 2) as media_gols,
    SUM(fp.vl_par_tot_gol) as total_gols
FROM dw.fct_par_partida fp
JOIN dw.dim_are_arena da ON fp.srk_are_are = da.srk_are_are
GROUP BY da.ds_are_nom, da.ds_are_est
HAVING COUNT(*) >= 50 -- Filtra arenas com poucos jogos
ORDER BY media_gols DESC
LIMIT 10;

-- 8. Maiores Goleadas da Historia
SELECT 
    dt.dt_tem_dat,
    dt.nr_tem_ano,
    tm.ds_tim_nom as mandante,
    tv.ds_tim_nom as visitante,
    fp.vl_par_man_pla as gols_mandante,
    fp.vl_par_vis_pla as gols_visitante,
    fp.vl_par_dif_gol as diferenca_gols,
    da.ds_are_nom as arena
FROM dw.fct_par_partida fp
JOIN dw.dim_tem_tempo dt ON fp.srk_tem_tem = dt.srk_tem_tem
JOIN dw.dim_tim_time tm ON fp.srk_tim_mandante = tm.srk_tim_tim
JOIN dw.dim_tim_time tv ON fp.srk_tim_visitante = tv.srk_tim_tim
JOIN dw.dim_are_arena da ON fp.srk_are_are = da.srk_are_are
WHERE fp.vl_par_dif_gol >= 5 -- Consideramos goleada histórica diferença >= 5
ORDER BY fp.vl_par_dif_gol DESC, fp.vl_par_tot_gol DESC
LIMIT 20;

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
FROM dw.vw_ranking_times
WHERE nr_tem_ano = (SELECT MAX(nr_tem_ano) FROM dw.dim_tem_tempo)
ORDER BY total_pontos DESC, saldo_gols DESC;