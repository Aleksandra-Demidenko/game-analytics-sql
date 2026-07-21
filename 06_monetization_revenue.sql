-- *****************************************************************
-- БЛОК 6: Анализ динамики выручки 
-- *****************************************************************

SELECT 
    DATE_TRUNC('month', m.dtime_pay) AS mm,
    type,
    SUM(m.cnt_buy * p.price) AS revenue
FROM skygame.monetary AS m
JOIN skygame.item_list AS i
   ON m.id_item_buy = i.id_item
JOIN skygame.log_prices AS p
   ON m.id_item_buy = p.id_item
  AND m.dtime_pay >= p.valid_from
  AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
GROUP BY 
    mm,
    type
ORDER BY 
    mm
