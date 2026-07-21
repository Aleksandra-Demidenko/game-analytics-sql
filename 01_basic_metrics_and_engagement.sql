-- **************************************************************************
-- БЛОК 1: БАЗОВЫЕ МЕТРИКИ АКТИВНОСТИ, АУДИТ ДАННЫХ И ВОВЛЕЧЕННОСТЬ ИГРОКОВ
-- ***************************************************************************

-- --------------------------------------------------------------------
-- ШАГ 1: Анализ игровых сессий и оценка качества трафика
-- --------------------------------------------------------------------

-- 1.1. Расчет общего числа сессий, количества целевых сессий (>5 мин) и их доли
SELECT 
    DATE_TRUNC('month', start_session) AS mm,
    COUNT(id_session) AS cnt_session_all,
    SUM(CASE WHEN end_session - start_session > INTERVAL '5 minute' THEN 1 ELSE 0 END) AS cnt_session_signif,
    SUM(CASE WHEN end_session - start_session > INTERVAL '5 minute' THEN 1.0 ELSE 0.0 END) / COUNT(id_session) AS share_signif
FROM skygame.game_sessions
GROUP BY mm
ORDER BY mm;

-- 1.2. Расчет динамики средней длительности целевых игровых сессий по месяцам

SELECT 
    DATE_TRUNC('month', start_session) AS mm,
    AVG(end_session - start_session) AS avg_session_duration
FROM skygame.game_sessions
WHERE end_session - start_session > INTERVAL '5 minute'
GROUP BY mm
ORDER BY mm;


-- --------------------------------------------------------------------
-- ШАГ 2: Анализ эффективности реферальной программы
-- --------------------------------------------------------------------

-- 2.1. Расчет общего числа уникальных приглашающих, инвайтов и конверсии в регистрации

SELECT 
    COUNT(DISTINCT id_user) AS cnt_user,
    COUNT(*) AS cnt_ref,
    SUM(ref_reg) / COUNT(*) AS share_reg
FROM skygame.referral;

-- 2.2. Выявление Топ-50 самых активных приглашающих пользователей

SELECT 
    id_user,
    COUNT(*) AS cnt_ref
FROM skygame.referral
GROUP BY id_user
ORDER BY cnt_ref DESC
LIMIT 50;

-- 2.3. Поиск эффективных юзеров (>5 приглашений, конверсия от 50%)

SELECT 
    id_user,
    COUNT(*) AS cnt_ref,
    SUM(ref_reg)::NUMERIC / COUNT(*) AS share_reg
FROM skygame.referral
GROUP BY id_user
HAVING COUNT(*) > 5
   AND SUM(ref_reg)::NUMERIC / COUNT(*) >= 0.5;


-- --------------------------------------------------------------------
-- ШАГ 3: Расчет базовых метрик аудитории (DAU, WAU, MAU)
-- --------------------------------------------------------------------

-- 3.1. Расчет DAU (Количество уникальных пользователей в день)

SELECT 
    DATE(start_session) AS day,
    COUNT(DISTINCT id_user) AS dau
FROM skygame.game_sessions
GROUP BY DATE(start_session)
ORDER BY day;

-- 3.2. Расчет WAU (Количество unique пользователей в неделю)

SELECT 
    DATE_TRUNC('week', start_session) AS week,
    COUNT(DISTINCT id_user) AS wau
FROM skygame.game_sessions
GROUP BY DATE_TRUNC('week', start_session)
ORDER BY week;

-- 3.3. Расчет MAU (Количество unique пользователей в месяц)

SELECT 
    DATE_TRUNC('month', start_session) AS month,
    COUNT(DISTINCT id_user) AS mau
FROM skygame.game_sessions
GROUP BY DATE_TRUNC('month', start_session)
ORDER BY month;

-- *Примечание:  Расчет Sticky Factor на основе DAU и MAU выполнен в Excel.


-- --------------------------------------------------------------------
-- ШАГ 4: Поиск самых вовлеченных игроков (Когорта 2022 года)
-- --------------------------------------------------------------------

SELECT 
    t1.id_user,
    EXTRACT(epoch FROM (t2.end_session - t2.start_session)) / 60 AS session_minutes 
FROM skygame.users AS t1
JOIN skygame.game_sessions AS t2 ON t1.id_user = t2.id_user
WHERE t2.end_session IS NOT NULL
  AND DATE_PART('year', t1.reg_date) = 2022
LIMIT 25;


-- --------------------------------------------------------------------
-- ШАГ 5: Технический аудит чистоты данных 
-- --------------------------------------------------------------------

-- 5.1. Оценка общего количества и доли "битых" сессий (где end_session IS NULL)

SELECT
    SUM(CASE WHEN t2.end_session IS NULL THEN 1 ELSE 0 END) AS cnt_broken_sessions,
    SUM(CASE WHEN t2.end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_broken_sessions
FROM skygame.users AS t1
JOIN skygame.game_sessions AS t2 ON t1.id_user = t2.id_user;

-- 5.2. Проверка доли "битых" сессий в разрезе операционных систем (dev_type)

SELECT 
    t1.dev_type,
    SUM(CASE WHEN t2.end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_broken_by_os
FROM skygame.users AS t1
JOIN skygame.game_sessions AS t2 ON t1.id_user = t2.id_user
GROUP BY t1.dev_type;


-- 5.3. Структурное распределение ошибок между операционными системами

SELECT 
    SUM(CASE WHEN t1.dev_type = 'ios' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_ios_in_broken,
    SUM(CASE WHEN t1.dev_type = 'android' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_android_in_broken
FROM skygame.users AS t1
JOIN skygame.game_sessions AS t2 ON t1.id_user = t2.id_user
WHERE t2.end_session IS NULL;
