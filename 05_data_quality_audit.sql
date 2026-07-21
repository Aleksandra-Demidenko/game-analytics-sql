-- *******************************************************************
-- БЛОК 5: Чистота данных и локализация технических сбоев 
-- *******************************************************************

-- 1. Оценка общего масштаба проблемы: количество и доля "битых" сессий во всей БД

SELECT
    SUM(CASE WHEN t2.end_session IS NULL THEN 1 ELSE 0 END) AS cnt_broken_sessions,
    SUM(CASE WHEN t2.end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_broken_sessions
FROM skygame.users AS t1
INNER JOIN skygame.game_sessions AS t2
   ON t1.id_user = t2.id_user;


-- 2. Расчет доли проблемых записей в разрере операционных систем

SELECT 
    t1.dev_type,
    SUM(CASE WHEN t2.end_session IS NULL THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_broken_by_os
FROM skygame.users AS t1
INNER JOIN skygame.game_sessions AS t2
   ON t1.id_user = t2.id_user
GROUP BY t1.dev_type;


-- 3. Распределение "битых" сессий между iOS и Android

SELECT 
    SUM(CASE WHEN t1.dev_type = 'ios' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_ios_in_broken,
    SUM(CASE WHEN t1.dev_type = 'android' THEN 1.0 ELSE 0.0 END) / COUNT(*) AS share_android_in_broken
FROM skygame.users AS t1
INNER JOIN skygame.game_sessions AS t2
   ON t1.id_user = t2.id_user
WHERE t2.end_session IS NULL;
