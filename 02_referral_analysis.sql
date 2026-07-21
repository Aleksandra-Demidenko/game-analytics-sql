-- ****************************************************************
-- БЛОК 2: Анализ эффективности реферальной маркетинговой программы
-- ****************************************************************

-- 1. Расчет общего числа уникальных приглашающих, общего количества инвайтов и общей конверсии (доли друзей, установивших игру)

SELECT 
    COUNT(DISTINCT id_user) AS cnt_user,
    COUNT(*) AS cnt_ref,
    SUM(ref_reg) / COUNT(*) AS share_reg
FROM skygame.referral


-- 2. Топ-50 пользователей, отправивших наибольшее количество приглашений
  
SELECT 
    id_user,
    COUNT(*) AS cnt_ref
FROM skygame.referral
GROUP BY id_user
ORDER BY cnt_ref DESC
LIMIT 50


-- 3. Поиск наиболее эффективных юзеров: пользователей с более 5 приглашениями и качественным трафиком (минимум 50% приглашенных друзей зарегистрировались)

SELECT    
      id_user,
      COUNT(*) AS cnt_ref,
      sum(ref_reg)/COUNT(*) AS share_reg
FROM skygame.referral
GROUP BY id_user
HAVING COUNT(*) > 5
  AND sum(ref_reg)/COUNT(*) >= 0.5
