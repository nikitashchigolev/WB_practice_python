-- Задание 1
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    birth_date DATE,
    sex CHAR(1),
    age INTEGER
);

CREATE TABLE items (
    item_id SERIAL PRIMARY KEY,
    description TEXT,
    price DECIMAL(10, 2),
    category VARCHAR(50)
);

CREATE TABLE ratings (
    rating_id SERIAL,
    item_id INTEGER REFERENCES items(item_id),
    user_id INTEGER REFERENCES users(user_id),
    review TEXT,
    rating INTEGER,
  	PRIMARY KEY (rating_id, user_id)
);


INSERT INTO users (birth_date, sex, age)
SELECT
    generated_birth_date AS birth_date,
    CASE WHEN random() < 0.5 THEN 'M' ELSE 'F' END AS sex,
    EXTRACT(YEAR FROM AGE(NOW(), generated_birth_date)) AS age
FROM (SELECT
          now() - (floor(random() * 365 * 60)::int || ' days')::interval AS generated_birth_date
      FROM generate_series(1, 20)) AS subquery;

INSERT INTO items (description, price, category)
SELECT
    md5(random()::text) || 'WB' AS description,
    (random() * 1000)::numeric(10, 2) AS price,
    (array['Electronics', 'Beauty', 'Health', 'Clothing', 'Entertainment'])[floor(random() * 5) + 1] AS category
FROM generate_series(1, 20) AS item_id;

INSERT INTO ratings (item_id, user_id, review, rating)
SELECT
    floor(random() * 20) + 1 AS item_id,
    floor(random() * 20) + 1 AS user_id,
    md5(random()::text) AS review,
    floor(random() * 5) + 1 AS rating
FROM generate_series(1, 20);
