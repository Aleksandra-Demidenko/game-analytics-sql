-- ************************************************************************
-- БЛОК 7: Анализ влияния повышения цен на продукт 
-- С 1 января 2023 года мы увеличили стоимость одного кристалла.
-- ************************************************************************

SELECT 
    DATE_TRUNC('month', m.dtime_pay) AS mm,
    -- Расчет среднего количества купленных кристаллов в рамках одной транзакции
    AVG(m.cnt_buy) AS avg_items_per_buy,
    -- Расчет совокупной выручки по категории с учетом исторических цен
    SUM(m.cnt_buy * p.price) AS total_revenue
FROM skygame.monetary AS m
 JOIN skygame.item_list AS i
   ON m.id_item_buy = i.id_item
 JOIN skygame.log_prices AS p
   ON m.id_item_buy = p.id_item
  AND m.dtime_pay >= p.valid_from
  AND m.dtime_pay <= COALESCE(p.valid_to, TO_DATE('01/01/3000', 'DD/MM/YYYY'))
WHERE i.name_item = 'Crystal' 
GROUP BY 
    mm
ORDER BY 
    mm
