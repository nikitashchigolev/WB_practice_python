-- Задание 1
WITH age_categories AS (
  SELECT 'young' AS category
  UNION ALL
  SELECT 'adult'
  UNION ALL
  SELECT 'old'
), 
cities AS (
  SELECT DISTINCT city
  FROM users
)

SELECT
  c.city,
  ac.category AS age_category,
  COUNT(u.city) AS customer_count
FROM cities c
CROSS JOIN age_categories ac
LEFT JOIN users u ON c.city = u.city
  AND (
    (ac.category = 'young' AND u.age >= 0 AND u.age <= 20) OR
    (ac.category = 'adult' AND u.age >= 21 AND u.age <= 49) OR
    (ac.category = 'old' AND u.age >= 50)
  )
GROUP BY c.city, ac.category
ORDER BY c.city, customer_count DESC, age_category;


-- Задание 2
SELECT 
round(avg(price)::numeric, 2) AS avg_price, 
category from products 
WHERE category IN (SELECT DISTINCT category FROM products WHERE name LIKE '%Hair%' OR name LIKE '%Home%') 
GROUP BY category


-- Задание 3
WITH without_bedding AS (
  SELECT * from sellers where category NOT IN ('Bedding')
),
three_category AS (
SELECT seller_id, 
count(category) AS total_categ, 
round(avg(rating)::NUMERIC, 2) AS avg_rating, 
sum(revenue) AS total_revenue,
CASE 
when count(category) > 1 AND sum(revenue) > 50000 THEN 'rich' 
WHEN count(category) > 1 AND sum(revenue) < 50000 THEN 'poor'
ELSE 'other' END as seller_type
FROM without_bedding
GROUP BY seller_id
)
Select * FROM three_category WHERE seller_type in ('rich','poor')

-- Задание 4

WITH rich_poor AS (
WITH without_bedding AS (
  SELECT * from sellers where category NOT IN ('Bedding')
),
three_category AS (
SELECT seller_id, 
count(category) AS total_categ,
min(TO_DATE(date_reg, 'DD/MM/YYYY')) as time_reg,
MIN(delivery_days) as min_day,
MAX(delivery_days) AS max_day,
round(avg(rating)::NUMERIC, 2) AS avg_rating, 
sum(revenue) AS total_revenue,
CASE 
when count(category) > 1 AND sum(revenue) > 50000 THEN 'rich' 
WHEN count(category) > 1 AND sum(revenue) < 50000 THEN 'poor'
ELSE 'other' END as seller_type
FROM without_bedding
GROUP BY seller_id
)
Select * FROM three_category WHERE seller_type = 'poor'  
)

SELECT seller_id,
('2023-10-25' - time_reg)/30 as month_from_registration,
(SELECT MAX(max_day) FROM rich_poor) - (SELECT MIN(min_day) FROM rich_poor) AS max_delivery_difference
FROM rich_poor
ORDER BY seller_id


-- Задание 5
WITH only_22 AS(
select seller_id,
category,
TO_DATE(date, 'DD/MM/YYYY') as time_type,
revenue 
from sellers WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YYYY')) = 2022
)
SELECT seller_id, 
string_agg(category, ' - ' ORDER BY category) AS category_pair
from only_22
GROUP BY seller_id
HAVING sum(revenue) > 75000
