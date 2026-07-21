-- ******************************************************************
-- БЛОК 3: Расчет базовых продуктовых метрик активности 
-- ********************************************************************


-- 1. Расчет DAU (Количество уникальных пользователей в день)

SELECT 
    DATE(start_session) AS day,
    COUNT(DISTINCT id_user) AS dau
FROM skygame.game_sessions
GROUP BY DATE(start_session)
ORDER BY day


-- 2. Расчет WAU (Количество уникальных пользователей в неделю)

SELECT 
    DATE_TRUNC('week', start_session) AS week,
    COUNT(DISTINCT id_user) AS wau
FROM skygame.game_sessions
GROUP BY DATE_TRUNC('week', start_session)
ORDER BY week


-- 3. Расчет MAU (Количество уникальных пользователей в месяц)

SELECT 
    DATE_TRUNC('month', start_session) AS month,
    COUNT(DISTINCT id_user) AS mau
FROM skygame.game_sessions
GROUP BY DATE_TRUNC('month', start_session)
ORDER BY month
