-- ====================================================================
-- БЛОК 8: Когортный анализ средних платежей
-- ====================================================================

SELECT  
       *,
      EXTRACT ('day' FROM ((SELECT MAX (dtime_pay) FROM skygame.monetary) - mm )/30) AS interv,
      avg_rev/(EXTRACT('day' FROM ((SELECT MAX (dtime_pay) FROM skygame.monetary) - mm )/30)) AS avg_rev_per_month
    
FROM (
    SELECT    
        DATE_TRUNC('month', reg_date) AS mm,
        SUM(cnt_buy * p.price) AS revenue,
        COUNT(DISTINCT m.id_user) AS cnt,
        SUM(cnt_buy * price) / COUNT(DISTINCT m.id_user) AS avg_rev
    FROM skygame.monetary AS m
     JOIN skygame.log_prices AS p
       ON m.id_item_buy = p.id_item
      AND m.dtime_pay >= p.valid_from
      AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
     JOIN skygame.users AS u
       ON m.id_user = u.id_user
    -- Отсекаем самые "свежие" когорты (младше 1 месяца), у которых еще не сформировалась история платежей
    WHERE u.reg_date < (SELECT MAX(dtime_pay) - INTERVAL '1 month' FROM skygame.monetary)
    GROUP BY mm
) AS t
ORDER BY cohort_month
