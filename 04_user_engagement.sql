-- **********************************************************************
-- БЛОК 4: Поиск самых вовлеченных игроков 
-- Анализ длительности сессий пользователей, зарегистрированных в 2022 году
-- ************************************************************************

SELECT 
    t1.id_user,
    EXTRACT(epoch FROM (t2.end_session - t2.start_session)) / 60 AS session_minutes 
FROM skygame.users AS t1
INNER JOIN skygame.game_sessions AS t2
   ON t1.id_user = t2.id_user
WHERE t2.end_session IS NOT NULL 
  AND DATE_PART('year', t1.reg_date) = 2022 -- Бизнес-требование: когорта игроков 2022 года
LIMIT 25
