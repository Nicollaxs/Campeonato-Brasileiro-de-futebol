
-- 1. DIMENSÃO TEMPO (DIM_TEM_TEMPO)

CREATE TABLE DIM_TEM_TEMPO (
    srk_tem_tem      INT NOT NULL,          
    dt_tem_dat       DATE,                 
    nr_tem_ano       INT,
    nr_tem_mes       INT,
    ds_tem_mes_nom   VARCHAR(20),           
    nr_tem_tri       INT,                 
    nr_tem_sem       INT,                  
    nr_tem_dia_mes   INT,
    nr_tem_dia_ano   INT,
    nr_tem_dia_sem   INT,                   
    ds_tem_dia_sem   VARCHAR(20),           
    fl_tem_fim_sem   BOOLEAN,              
    ds_tem_tmp       VARCHAR(10),          
    hr_tem_hor       TIME,                  
    
    CONSTRAINT PK_DIM_TEMPO PRIMARY KEY (srk_tem_tem)
);

-- 2. DIMENSÃO TIME (DIM_TIM_TIME)
CREATE TABLE DIM_TIM_TIME (
    srk_tim_tim      INT NOT NULL,          
    nk_tim_tim       VARCHAR(100),          
    ds_tim_nom       VARCHAR(100),          
    ds_tim_est       VARCHAR(2),            
    ds_tim_reg       VARCHAR(50),           
    fl_tim_pri_div   BOOLEAN,               
    
    CONSTRAINT PK_DIM_TIME PRIMARY KEY (srk_tim_tim)
);


-- 3. DIMENSÃO ARENA (DIM_ARE_ARENA)

CREATE TABLE DIM_ARE_ARENA (
    srk_are_are      INT NOT NULL,          
    nk_are_are       VARCHAR(150),          
    ds_are_nom       VARCHAR(150),         
    ds_are_est       VARCHAR(2),            
    ds_are_reg       VARCHAR(50),           
    qt_are_cap       INT,                   
    ds_are_tip_gra   VARCHAR(50),           
    
    CONSTRAINT PK_DIM_ARENA PRIMARY KEY (srk_are_are)
);


-- 4. DIMENSÃO RESULTADO (DIM_RES_RESULTADO)

CREATE TABLE DIM_RES_RESULTADO (
    srk_res_res      INT NOT NULL,          
    ds_res_ven       VARCHAR(50),           
    ds_res_tip_res   VARCHAR(50),           
    fl_res_equ       BOOLEAN,               
    fl_res_gol       BOOLEAN,               
    ds_res_cat_gol   VARCHAR(50),           
    
    CONSTRAINT PK_DIM_RESULTADO PRIMARY KEY (srk_res_res)
);


-- 5. TABELA FATO PARTIDA (FCT_PAR_PARTIDA)

CREATE TABLE FCT_PAR_PARTIDA (
    -- Chaves
    srk_par_par         INT NOT NULL,       
    srk_tem_tem         INT NOT NULL,       
    srk_tim_mandante    INT NOT NULL,       
    srk_tim_visitante   INT NOT NULL,      
    srk_are_are         INT NOT NULL,      
    srk_res_res         INT NOT NULL,      

    -- Placar e Gols
    vl_par_man_pla      INT,                
    vl_par_vis_pla      INT,                
    vl_par_tot_gol      INT,                
    vl_par_dif_gol      INT,                
    qt_par_gol_con      INT,                
    qt_par_gol_pen      INT,                

    -- Cartões
    qt_par_car_ama      INT,                
    qt_par_car_ver      INT,                
    qt_par_car_tot      INT,                

    -- KPIs Calculados (Taxas e Eficiência)
    vl_par_man_tax_con  DECIMAL(10,2),      
    vl_par_vis_tax_con  DECIMAL(10,2),      
    vl_par_man_efi      DECIMAL(10,2),      
    vl_par_vis_efi      DECIMAL(10,2),      

    -- Estatísticas Mandante
    qt_par_man_chu      INT,                
    qt_par_man_chu_alv  INT,                
    vl_par_man_pos      DECIMAL(5,2),       
    qt_par_man_pas      INT,                
    vl_par_man_pre_pas  DECIMAL(5,2),       
    qt_par_man_fal      INT,                
    qt_par_man_imp      INT,                
    qt_par_man_esc      INT,                

    -- Estatísticas Visitante
    qt_par_vis_chu      INT,
    qt_par_vis_chu_alv  INT,
    vl_par_vis_pos      DECIMAL(5,2),
    qt_par_vis_pas      INT,
    vl_par_vis_pre_pas  DECIMAL(5,2),
    qt_par_vis_fal      INT,
    qt_par_vis_imp      INT,
    qt_par_vis_esc      INT,

    -- Constraints (PK e FKs)
    CONSTRAINT PK_FCT_PARTIDA PRIMARY KEY (srk_par_par),
    CONSTRAINT FK_PAR_TEMPO FOREIGN KEY (srk_tem_tem) REFERENCES DIM_TEM_TEMPO (srk_tem_tem),
    CONSTRAINT FK_PAR_MANDANTE FOREIGN KEY (srk_tim_mandante) REFERENCES DIM_TIM_TIME (srk_tim_tim),
    CONSTRAINT FK_PAR_VISITANTE FOREIGN KEY (srk_tim_visitante) REFERENCES DIM_TIM_TIME (srk_tim_tim),
    CONSTRAINT FK_PAR_ARENA FOREIGN KEY (srk_are_are) REFERENCES DIM_ARE_ARENA (srk_are_are),
    CONSTRAINT FK_PAR_RESULTADO FOREIGN KEY (srk_res_res) REFERENCES DIM_RES_RESULTADO (srk_res_res)
);