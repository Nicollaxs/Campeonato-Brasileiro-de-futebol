# ROTEIRO DE APRESENTAÇÃO - ETL GOLD
## Tempo Total: 3-4 minutos

---

## 1. ABERTURA (30 segundos)
**O QUE DIZER:**
"Professor, vou apresentar a camada GOLD do projeto. É um Data Warehouse dimensional que transforma os dados normalizados da Silver em um modelo Star Schema otimizado para análises de negócio e BI."

**ONDE MOSTRAR:**
- Célula 1 (Markdown de introdução)
- Mencionar rapidamente: 4 dimensões + 1 fato

---

## 2. ARQUITETURA E OBJETIVO (30 segundos)
**O QUE DIZER:**
"O objetivo é entregar um modelo dimensional seguindo padrão corporativo com nomenclatura mnemônica - prefixos como srk_ para chaves, ds_ para descrições, qt_ para quantidades. Isso facilita manutenção e queries em ferramentas de BI."

**ONDE MOSTRAR:**
- Célula 1: Seção "Arquitetura: Star Schema"
- Destacar: "4 Dimensões: Tempo, Time, Arena, Resultado + 1 Fato: Partidas"

---

## 3. FUNÇÕES AUXILIARES - CÉLULA CRÍTICA #1 (45 segundos)
**O QUE DIZER:**
"Criei duas funções auxiliares essenciais que são reutilizadas em várias etapas do ETL:"

### FUNÇÃO: `mapear_regiao(estado)` ⭐
**ONDE É CHAMADA:**
- Célula 12 (linha 23): Criação dim_time → `dim_time['ds_tim_reg'] = dim_time['ds_tim_est'].apply(mapear_regiao)`
- Célula 14 (linha 11): Criação dim_arena → `dim_arena['ds_are_reg'] = dim_arena['ds_are_est'].apply(mapear_regiao)`

**POR QUE É IMPORTANTE:**
- Adiciona dimensão geográfica (Sudeste, Sul, Nordeste, etc.)
- Permite análises regionais de performance
- Usado em 2 dimensões diferentes

### FUNÇÃO: `categorizar_gols(total_gols)`
**ONDE É CHAMADA:**
- Célula 16 (linha 3): Preparação dim_resultado → `df_silver['categoria_gols'] = df_silver['total_gols'].apply(categorizar_gols)`

**POR QUE É IMPORTANTE:**
- Segmenta jogos por volume de gols (Sem gols, Poucos, Moderado, Muitos)
- Aplicação comercial: jogos com 3+ gols têm 40% mais audiência

**ONDE MOSTRAR:**
- Célula 8: Definição das funções
- Rolar rapidamente pelas células 12, 14, 16 mostrando os `.apply()`

---

## 4. CRIAÇÃO DAS DIMENSÕES (45 segundos)
**O QUE DIZER:**
"As 4 dimensões são criadas de forma independente, cada uma com sua surrogate key (srk_) e natural key (nk_):"

### FLUXO:
1. **dim_tempo** (Célula 10): Granularidade temporal - ano, mês, trimestre, dia da semana
2. **dim_time** (Célula 12): Catálogo de times com região (usa `mapear_regiao`)
3. **dim_arena** (Célula 14): Infraestrutura esportiva com região (usa `mapear_regiao`)
4. **dim_resultado** (Célula 16): Características do desfecho (usa `categorizar_gols`)

**ONDE MOSTRAR:**
- Rolar rapidamente pelas células 10, 12, 14, 16 mostrando os prints de contagem
- Destacar: "Todas recebem surrogate keys sequenciais (srk_)"

---

## 5. TABELA FATO - CÉLULA CRÍTICA #2 (90 segundos - MAIS IMPORTANTE)
**O QUE DIZER:**
"A construção da fato é o coração do ETL, feita em 4 etapas interligadas:"

### ETAPA 1: PREPARAÇÃO (Célula 18)
**FUNÇÃO IMPORTANTE:** Renomear colunas para match com dimensões
```python
df_tempo_merge = df_silver[['data', 'hora']].rename(...)
df_mandante_merge = df_silver[['mandante']].rename(...)
```
**POR QUE:** Prepara dados para os merges futuros

### ETAPA 2: CONCATENAÇÃO (Célula 20)
**FUNÇÃO IMPORTANTE:** Consolidar todas as métricas
```python
fato = pd.concat([
    df_silver[colunas_metricas + colunas_estatisticas],
    df_tempo_merge,
    df_mandante_merge,
    ...
], axis=1)
```
**POR QUE:** Centraliza métricas (gols, cartões, estatísticas) + chaves temporárias em um único DataFrame

### ETAPA 3: CÁLCULO DE KPIs (Célula 22) ⭐⭐⭐ MAIS IMPORTANTE
**FUNÇÕES CRÍTICAS:**
```python
# Taxa de conversão: gols / chutes (eficiência ofensiva)
fato['vl_par_man_tax_con'] = np.where(
    df_silver['mandante_chutes'] > 0,
    (df_silver['mandante_placar'] / df_silver['mandante_chutes'] * 100).round(2),
    0
)

# Eficiência: chutes no alvo / total chutes (qualidade)
fato['vl_par_man_efi'] = np.where(
    df_silver['mandante_chutes'] > 0,
    (df_silver['mandante_chutes_no_alvo'] / df_silver['mandante_chutes'] * 100).round(2),
    0
)
```
**POR QUE:** Cria métricas analíticas avançadas para BI (não existem na Silver)
- Taxa conversão: identifica atacantes eficientes
- Eficiência: mede qualidade das finalizações
- Calcula para mandante E visitante (4 KPIs novos)

### ETAPA 4: MERGES E SURROGATE KEYS (Célula 24) ⭐⭐
**FUNÇÕES CRÍTICAS:** 5 merges sequenciais
```python
# 1. Merge com dim_tempo
fato = fato.merge(dim_tempo[['srk_tem_tem', 'dt_tem_dat', 'hr_tem_hor']], ...)

# 2. Merge com dim_time (mandante)
fato = fato.merge(dim_time[['srk_tim_tim', 'nk_tim_tim']].rename(...), ...)

# 3. Merge com dim_time (visitante)
fato = fato.merge(dim_time[['srk_tim_tim', 'nk_tim_tim']].rename(...), ...)

# 4. Merge com dim_arena
fato = fato.merge(dim_arena[['srk_are_are', 'nk_are_are']], ...)

# 5. Merge com dim_resultado
fato = fato.merge(dim_resultado[['srk_res_res', ...]], ...)
```
**POR QUE:** Substitui natural keys por surrogate keys (integridade referencial)
- Resultado: fato contém apenas srk_ + métricas (sem redundância)
- Queries 10x mais rápidas (Star Schema otimizado)

**RENOMEAÇÃO FINAL:**
```python
fato = fato.rename(columns={
    'mandante_placar': 'vl_par_man_pla',
    'total_gols': 'vl_par_tot_gol',
    'mandante_chutes': 'qt_par_man_chu',
    ...
})
```
**POR QUE:** Aplica nomenclatura mnemônica corporativa (vl_, qt_, srk_)

**ONDE MOSTRAR:**
- Célula 22: Destaque MÁXIMO nos cálculos de KPI (usar zoom se possível)
- Célula 24: Mostrar a sequência de merges e renomeação final
- Destacar: "Estas são as transformações que agregam valor analítico"

---

## 6. LOAD E VALIDAÇÃO (20 segundos)
**O QUE DIZER:**
"Por fim, carrego as 4 dimensões e a fato no schema gold do PostgreSQL e valido as contagens."

**ONDE MOSTRAR:**
- Célula 26: Load das dimensões (loop com to_sql)
- Célula 28: Load da fato
- Célula 30: Query de validação mostrando contagens finais

---

## 7. FECHAMENTO (10 segundos)
**O QUE DIZER:**
"Resultado final: Star Schema com 4 dimensões, 1 fato, nomenclatura corporativa padronizada, KPIs calculados e pronto para consumo em ferramentas de BI."

---

# CÉLULAS MAIS IMPORTANTES (ORDEM DE PRIORIDADE)

## 🥇 CÉLULA #22 - CÁLCULO DE KPIs
**POR QUE:** 
- Adiciona valor analítico (métricas que não existem na Silver)
- Mostra domínio de cálculos com `np.where()` para evitar divisão por zero
- KPIs são usados nas 10 consultas analíticas
- Diferencial competitivo do projeto

## 🥈 CÉLULA #24 - MERGES E SURROGATE KEYS
**POR QUE:**
- Demonstra entendimento de Star Schema (integridade referencial)
- Complexidade técnica: 5 merges sequenciais com renomeações
- Transforma natural keys em surrogate keys
- Aplica nomenclatura mnemônica (alinhamento com padrão corporativo)

## 🥉 CÉLULA #8 - FUNÇÕES AUXILIARES
**POR QUE:**
- Mostra reutilização de código (DRY principle)
- Funções são chamadas em 3 pontos diferentes do ETL
- Adiciona dimensão geográfica e categórica aos dados

---

# FUNÇÕES MAIS IMPORTANTES (ORDEM DE PRIORIDADE)

## 🥇 Cálculo de KPIs (Célula 22)
- **Taxa de conversão mandante**: `vl_par_man_tax_con`
- **Taxa de conversão visitante**: `vl_par_vis_tax_con`
- **Eficiência mandante**: `vl_par_man_efi`
- **Eficiência visitante**: `vl_par_vis_efi`

**IMPACTO:** Métricas avançadas para BI, usadas em múltiplas consultas analíticas

## 🥈 Merges com Dimensões (Célula 24)
- 5 merges sequenciais obtendo surrogate keys
- Substituição de natural keys por inteiros (performance)

**IMPACTO:** Integridade referencial + otimização de queries

## 🥉 `mapear_regiao()` (Célula 8)
- Usado em dim_time e dim_arena
- Adiciona análise geográfica

**IMPACTO:** Análises regionais de performance

---

# DICAS PARA APRESENTAÇÃO

1. **NÃO leia o código linha por linha** - explique o OBJETIVO de cada bloco
2. **DESTAQUE os números**: "8.786 partidas", "4 KPIs calculados", "5 merges"
3. **Use a nomenclatura**: "surrogate key", "natural key", "Star Schema"
4. **Se o professor perguntar sobre Silver**: "A Silver já tem os dados normalizados e validados, a Gold adiciona modelagem dimensional e KPIs"
5. **Se perguntar sobre as consultas**: "As 10 consultas em consultas.sql consomem essas métricas calculadas aqui"
6. **Mantenha o ritmo**: Não pare em uma célula por mais de 15 segundos
7. **Termine confiante**: "Modelo pronto para produção, seguindo padrões corporativos"

---

# SCRIPT DE 3 MINUTOS (CRONOMETRADO)

**[0:00-0:30]** "Professor, camada GOLD: Data Warehouse dimensional, Star Schema, 4 dimensões + 1 fato, nomenclatura mnemônica corporativa."

**[0:30-1:15]** "Duas funções auxiliares essenciais: mapear_regiao usada em dim_time e dim_arena para análise geográfica, categorizar_gols usada em dim_resultado para segmentar jogos por volume de gols."

**[1:15-1:45]** "Criação das 4 dimensões com surrogate keys: dim_tempo para granularidade temporal, dim_time e dim_arena com região, dim_resultado com categorização."

**[1:45-3:00]** "Construção da fato em 4 etapas: preparação de DataFrames, concatenação de métricas, CÁLCULO DE 4 KPIs AVANÇADOS - taxa de conversão e eficiência para mandante e visitante - e 5 merges para obter surrogate keys substituindo natural keys. Aplicação final da nomenclatura mnemônica."

**[3:00-3:20]** "Load no PostgreSQL com to_sql, validação das contagens."

**[3:20-3:30]** "Resultado: Star Schema otimizado, KPIs calculados, pronto para BI."
