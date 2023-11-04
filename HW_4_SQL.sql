-- Задание 1
-- Заметим, что факт доставки подтверждается только в том случае, если заказ не отменен, поэтому считаем только заказы со статусом Approved
SELECT 
DISTINCT customer_id, name
FROM orders
INNER JOIN customers
USING(customer_id)
where EXTRACT(EPOCH FROM TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS')) = 
(SELECT 
EXTRACT(EPOCH FROM TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS')) as diff 
FROM orders
order by diff DESC
LIMIT 1)
AND order_status = 'Approved'
ORDER BY customer_id
LIMIT 1;

-- Задание 2
-- Также рассматриваем заказы только со статусом Approved
SELECT 
name,
ROUND(AVG(EXTRACT(EPOCH FROM TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS'))) / 86400) AS avg_days,
sum(order_ammount)
from orders
INNER JOIN customers
USING(customer_id)
where order_status = 'Approved'
group by customer_id, name
having count(*) = (select 
count(*)
from orders
where order_status = 'Approved'
group by customer_id
Order by count(*) DESC
LIMIT 1)
ORDER BY sum(order_ammount) DESC;

-- Задание 3 
-- В данном задании создаем cte для двух выборок данных: количество подтвержденных заказов с задержкой и всех отмененных по пользователям

WITH delay AS (SELECT 
customer_id,
count(*) as count_delay
FROM orders
WHERE (EXTRACT(EPOCH FROM TO_TIMESTAMP(shipment_date, 'YYYY-MM-DD HH24:MI:SS') - TO_TIMESTAMP(order_date, 'YYYY-MM-DD HH24:MI:SS')) > 432000 and order_status = 'Approved')
group By customer_id),
cancel as (SELECT 
customer_id,
count(*) as count_cancel
FROM orders
WHERE order_status = 'Cancel'
group By customer_id)

SELECT name, 
COALESCE(count_delay, 0) As count_delay_result, 
COALESCE(count_cancel, 0) As count_cancel_result, 
COALESCE(count_delay, 0) + COALESCE(count_cancel, 0) as sum_orders
from customers
left OUTER join delay using (customer_id)
left OUTER join cancel using (customer_id)
order by sum_orders DESC;

-- Задание 4
WITH cat_amm AS (Select 
product_category,
sum(order_ammount) as sum_category
from products 
inner join 
orders 
using(product_id)
group by product_category),

max_local_order AS (SELECT p.product_category, p.product_name AS max_order_ammount_product_id, P.product_id
FROM products p
JOIN (SELECT 
p1.product_category, MAX(o1.order_ammount) AS max_order_ammount
FROM products p1
JOIN orders o1 USING(product_id)
GROUP BY p1.product_category) max_order_ammount_per_category ON p.product_category = max_order_ammount_per_category.product_category
JOIN orders o ON p.product_id = o.product_id
AND o.order_ammount = max_order_ammount_per_category.max_order_ammount
)

select cat_amm.product_category, cat_amm.sum_category,
(SELECT product_category 
FROM cat_amm 
WHERE sum_category = (SELECT MAX(sum_category) FROM cat_amm)
) AS max_category,
max_local_order.max_order_ammount_product_id,
product_id
from cat_amm
INNER join max_local_order on cat_amm.product_category = max_local_order.product_category;

-- Данный запрос можно проверить, найдя продукт с максимальной суммой продаж, например, для категории напитки
Select * from 
orders,
products 
where orders.product_id = products.product_id and 
product_name in (select distinct product_name from products where product_category = 'Напитки')
ORDER By order_ammount DESC
LIMIT 1;

