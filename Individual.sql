-- Создание таблицы
CREATE TABLE UserClicks (
    event_id INT PRIMARY KEY,
    user_id INT,
    event_date DATE,
    session_id INT,
    element_name VARCHAR(255),
    event_profit INT,
    ver VARCHAR(255),
    platform VARCHAR(255)
);

-- Создание последовательности для event_id
CREATE SEQUENCE event_id_sequence;

-- Создание последовательности для session_id
CREATE SEQUENCE session_id_sequence;

-- Генерация данных по выявленным условиям
WITH user_sessions AS (
  SELECT
    nextval('event_id_sequence') AS event_id,
    floor(random() * 1000) AS user_id,
    nextval('session_id_sequence') AS session_id,
    element_name,
    ver,
    platform,
    CASE
        WHEN element_name = 'Advert Banner' AND ver = 'Original' AND (platform = 'Desktop' OR platform = 'Mobile') THEN floor(random() * 100) + 50
        WHEN element_name = 'Work and Partnership' AND ver = 'Original' AND platform = 'Desktop' THEN floor(random() * 100) + 50
        WHEN (element_name = 'Product Card' AND ver = 'Global' AND (platform = 'Desktop' OR platform = 'Mobile'))
            OR (element_name = 'Product Card' AND ver = 'Original' AND platform = 'Desktop') THEN floor(random() * 100) + 50
        WHEN element_name = 'Buy Now' AND ver = 'Original' AND (platform = 'Desktop' OR platform = 'Mobile') THEN floor(random() * 100) + 50
        ELSE floor(random() * 100)
    END AS event_profit,
    generate_series(
        timestamp '2023-01-01 00:00:00',
        timestamp '2023-01-01 23:59:59',
        interval '1 minute'
    ) + (random() * interval '1 hour') AS event_date
  FROM (
    SELECT
      nextval('session_id_sequence') AS session_id,
      floor(random() * 1000) AS user_id,
      CASE
        WHEN random() < 0.2 THEN 'Advert Banner'
        WHEN random() < 0.4 THEN 'Work and Partnership'
        WHEN random() < 0.6 THEN 'Product Card'
        ELSE 'Buy Now'
      END AS element_name,
      CASE
        WHEN random() < 0.5 THEN 'Global'
        ELSE 'Original'
      END AS ver,
      CASE
        WHEN random() < 0.5 THEN 'Desktop'
        ELSE 'Mobile'
      END AS platform
    FROM generate_series(1, 200)
  ) subquery
)
INSERT INTO UserClicks (event_id, user_id, event_date, session_id, element_name, event_profit, ver, platform)
SELECT event_id, user_id, event_date, session_id, element_name, event_profit, ver, platform
FROM user_sessions
ORDER BY random()
LIMIT 1000;

select * from userclicks

-- Конверсия в целевое действие 
SELECT
    ver,
    platform,
    COUNT(CASE WHEN element_name = 'Buy Now' THEN 1 ELSE NULL END) AS conversions,
    COUNT(*) AS total_visits,
    ROUND((COUNT(CASE WHEN element_name = 'Buy Now' THEN 1 ELSE NULL END)::float / COUNT(*))::numeric, 3) AS conversion_rate
FROM UserClicks
GROUP BY ver, platform
ORDER BY ver, platform;

-- Средний доход с пользователя (ARPU - Average Revenue Per User)
SELECT
    ver,
    platform,
    SUM(event_profit) AS total_revenue,
    COUNT(DISTINCT user_id) AS total_users,
    ROUND((SUM(event_profit)::float / COUNT(DISTINCT user_id))::NUMERIC, 3) AS arpu
FROM UserClicks
GROUP BY ver, platform
ORDER BY ver, platform;

-- Средний доход с сессии (ARPS - Average Revenue Per Session)
SELECT
    ver,
    platform,
    SUM(event_profit) AS total_revenue,
    COUNT(session_id) AS total_sessions,
    ROUND((SUM(event_profit)::float / COUNT(session_id))::NUMERIC, 3) AS arps
FROM UserClicks
GROUP BY ver, platform
ORDER BY ver, platform;

-- Средний доход с элемента (ARPE - Average Revenue Per Element)
SELECT
    ver,
    platform,
    element_name,
    SUM(event_profit) AS total_revenue,
    COUNT(*) AS total_clicks,
    ROUND((SUM(event_profit)::float / COUNT(*))::NUMERIC, 3) AS arpe
FROM UserClicks
GROUP BY ver, platform, element_name
ORDER BY ver, platform, element_name;
