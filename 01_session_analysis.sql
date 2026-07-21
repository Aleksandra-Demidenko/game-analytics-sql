-- ******************************************************************
-- БЛОК 1: Анализ игровых сессий и оценка качества трафика по месяцам
-- ******************************************************************

-- 1. Расчет общего числа сессий, количества целевых сессий (>5 мин) и их доли

SELECT 
    DATE_TRUNC('month', start_session) AS mm,
    COUNT(id_session) AS cnt_session_all,
    SUM(CASE WHEN end_session - start_session > INTERVAL '5 minute' THEN 1 ELSE 0 END) AS cnt_session_signif,
    SUM(CASE WHEN end_session - start_session > INTERVAL '5 minute' THEN 1.0 ELSE 0.0 END) / COUNT(id_session) AS share_signif
FROM skygame.game_sessions
GROUP BY mm
ORDER BY mm

-- 2. Расчет динамики средней длительности целевых игровых сессий в соответствии с бизнес-требованием, короткие сессии (<5 мин) не учитываются
    
SELECT 
    DATE_TRUNC('month', start_session) AS mm,
    AVG(end_session - start_session) AS avg_session_duration
FROM skygame.game_sessions
WHERE end_session - start_session > INTERVAL '5 minute'
GROUP BY mm
ORDER BY mm
