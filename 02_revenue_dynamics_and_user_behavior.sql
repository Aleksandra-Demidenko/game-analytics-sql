-- ====================================================================
-- БЛОК 2: АНАЛИЗ ДИНАМИКИ ВЫРУЧКИ И ПОВЕДЕНИЯ КЛИЕНТОВ
-- ====================================================================

-- --------------------------------------------------------------------
-- ШАГ 1: Анализ динамики выручки по категориям предметов
-- --------------------------------------------------------------------

SELECT 
    DATE_TRUNC('month', m.dtime_pay) AS mm,
    i.type,
    SUM(m.cnt_buy * p.price) AS revenue
FROM skygame.monetary AS m
INNER JOIN skygame.item_list AS i ON m.id_item_buy = i.id_item
INNER JOIN skygame.log_prices AS p ON m.id_item_buy = p.id_item
  AND m.dtime_pay >= p.valid_from
  AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
GROUP BY mm, i.type
ORDER BY mm, revenue DESC;


-- --------------------------------------------------------------------
-- ШАГ 2: Анализ влияния повышения цен на Кристаллы 
-- --------------------------------------------------------------------

SELECT 
    DATE_TRUNC('month', m.dtime_pay) AS mm,
    AVG(m.cnt_buy) AS avg_items_per_buy,
    SUM(m.cnt_buy * p.price) AS total_revenue
FROM skygame.monetary AS m
INNER JOIN skygame.item_list AS i ON m.id_item_buy = i.id_item
INNER JOIN skygame.log_prices AS p ON m.id_item_buy = p.id_item
  AND m.dtime_pay >= p.valid_from
  AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
WHERE i.name_item = 'Crystal'
GROUP BY mm
ORDER BY mm;


-- --------------------------------------------------------------------
-- ШАГ 3: Когортный анализ средних платежей по месяцу регистрации 
-- --------------------------------------------------------------------

SELECT  
    *,
    EXTRACT('day' FROM ((SELECT MAX(dtime_pay) FROM skygame.monetary) - mm)) / 30 AS interv,
    avg_rev / (EXTRACT('day' FROM ((SELECT MAX(dtime_pay) FROM skygame.monetary) - mm)) / 30, 0) AS avg_rev_per_month
FROM (
    SELECT    
        DATE_TRUNC('month', u.reg_date) AS mm,
        SUM(m.cnt_buy * p.price) AS revenue,
        COUNT(DISTINCT m.id_user) AS cnt,
        SUM(m.cnt_buy * p.price) / COUNT(DISTINCT m.id_user) AS avg_rev
    FROM skygame.monetary AS m
    INNER JOIN skygame.log_prices AS p ON m.id_item_buy = p.id_item
      AND m.dtime_pay >= p.valid_from
      AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
    INNER JOIN skygame.users AS u ON m.id_user = u.id_user
    WHERE u.reg_date < (SELECT MAX(dtime_pay) - INTERVAL '1 month' FROM skygame.monetary)
    GROUP BY mm
) AS t



-- --------------------------------------------------------------------
-- ШАГ 4: Проверка гипотезы о качестве рекламных кампаний (Когорта 11-12.2022)
-- Оценка среднего времени сессии у "лояльных" игроков из таргетированной рекламы
-- --------------------------------------------------------------------
  
SELECT 
    CASE 
        WHEN t2.reg_date >= '2022-11-01' AND t2.reg_date < '2023-01-01' THEN 'Когорта 11-12.2022' 
        ELSE 'Остальные когорты' 
    END AS user_cohort,
    AVG(t1.end_session - t1.start_session) AS avg_session_duration
FROM skygame.game_sessions AS t1
LEFT JOIN skygame.users AS t2 ON t1.id_user = t2.id_user
WHERE t1.end_session - t1.start_session > INTERVAL '5 minute' 
GROUP BY user_cohort;


-- --------------------------------------------------------------------
-- ШАГ 5: Расчет комплексного K-factor (Коэффициента "вирусности" игры)
-- --------------------------------------------------------------------

WITH k_f AS (
    SELECT 
        -- Расчет базового коэффициента виральности на основе реферальных приглашений
        COUNT(t2.ref_reg)::FLOAT / COUNT(DISTINCT t1.id_user) * SUM(COALESCE(t2.ref_reg, 0)) / COUNT(t2.ref_reg) AS kf
    FROM skygame.users AS t1
    LEFT JOIN skygame.referral AS t2 ON t1.id_user = t2.id_user
),
v_s AS (
    SELECT 
        -- Вычисление среднего объема регистраций новых пользователей по месяцам
        AVG(cnt) AS avg_registrations_per_month
    FROM (
        SELECT 
            COUNT(*) AS cnt, 
            DATE_TRUNC('month', reg_date) AS mm
        FROM skygame.users
        GROUP BY mm
    ) AS t
)
-- Финальный расчет итогового K-factor продукта
SELECT 
    (SELECT kf FROM k_f) * (SELECT avg_registrations_per_month FROM v_s) AS final_k_factor;
