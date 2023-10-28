-- 3.	
SELECT 
DISTINCT orders.user_id, 
first_name, 
last_name
FROM users, orders
where users.id = orders.user_id and status = 'create_order'
AND EXTRACT(YEAR FROM (TO_DATE(orders._order_date, 'DD/MM/YYYY'))) = 2022
AND EXTRACT(MONTH FROM (TO_DATE(orders._order_date, 'DD/MM/YYYY'))) BETWEEN 9 AND 11;

/*Поскольку среди пользователей могут быть тезки и однофамильцы, для однозначной идентификации заселектим не только по имени, но и по соответствующему id.
*
*4. 
*Стоит заострить внимание на следующем:
*Каждый заказ имеет два статуса ‘create_order’ и ‘cancel_order’. Поэтому существует два случая:
*Если флоу статусов таков, что status = ‘cancel_order’ является терминальным статусом, и что откатиться на оформление и дальнейшую оплату заказа нельзя, 
*то нет смысла рассчитывать new_price для таких записей, тогда ищем необходимые заказы только со статусом ‘create_order’.
*Если статус не терминальный и из него можно попасть в статус, в котором можно будет оплатить, тогда есть смысл считать скидку в статусе ‘cancel_order’.
*По условию задачи нужно использовать первый вариант:
*/

ALTER TABLE orders
ADD COLUMN discount REAL,
ADD COLUMN new_price REAL;

UPDATE orders
SET discount = CASE
  WHEN price = (
    SELECT price
    FROM orders
    WHERE status = 'create_order'
    ORDER BY price DESC
    LIMIT 1
  ) THEN price * 0.10
  ELSE 0
END;

UPDATE orders
SET new_price = CASE
  WHEN price = (
    SELECT price
    FROM orders
    WHERE status = 'create_order'
    ORDER BY price DESC
    LIMIT 1
  ) THEN price - discount
  ELSE price
END;

-- 5.	
DELETE FROM orders
WHERE status = 'cancel_order' OR items > 4;

-- Для проверки значений столбцов можно использовать следующие запросы:
SELECT DISTINCT status
FROM orders;

SELECT DISTINCT items
FROM orders;

-- 6.
SELECT SUBSTRING(REPLACE(email, '.com', '') FROM POSITION('@' IN email) + 1) AS mail_index
FROM users
WHERE gender = 'Male'
GROUP BY mail_index
ORDER BY COUNT(*) DESC
LIMIT 3;
