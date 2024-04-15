-- Создание схемы и таблиц
CREATE SCHEMA IF NOT EXISTS mytabs;

-- Таблица для фильмов
CREATE TABLE IF NOT EXISTS mytabs.tab1 (
    id SERIAL PRIMARY KEY,
    movie_title VARCHAR(255),
    release_year INT,
    studio VARCHAR(255)
);

-- Таблица для атрибутов фильма
CREATE TABLE IF NOT EXISTS mytabs.tab2 (
    id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES mytabs.tab1(id),
    screenplay_author VARCHAR(255),
    director VARCHAR(255),
    awards_count INT
);

-- Таблица для актеров
CREATE TABLE IF NOT EXISTS mytabs.tab3 (
    id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES mytabs.tab1(id),
    actor_name VARCHAR(255),
    role VARCHAR(255)
);

-- Заполнение таблиц данными
INSERT INTO mytabs.tab1 (movie_title, release_year, studio) VALUES
    ('Inception', 2010, 'Warner Bros.'),
    ('The Dark Knight', 2008, 'Warner Bros.'),
    ('The Godfather', 1972, 'Paramount Pictures'),
    ('Pulp Fiction', 1994, 'Miramax Films'),
    ('Fight Club', 1999, '20th Century Fox'),
    ('Forrest Gump', 1994, 'Paramount Pictures'),
    ('The Shawshank Redemption', 1994, 'Castle Rock Entertainment');

INSERT INTO mytabs.tab2 (movie_id, screenplay_author, director, awards_count) VALUES
    (1, 'Christopher Nolan', 'Christopher Nolan', 4),
    (2, 'Christopher Nolan', 'Christopher Nolan', 2),
    (3, 'Francis Ford Coppola', 'Francis Ford Coppola', 3),
    (4, 'Quentin Tarantino', 'Quentin Tarantino', 1),
    (5, 'Chuck Palahniuk', 'David Fincher', 0),
    (6, 'Winston Groom', 'Robert Zemeckis', 6),
    (7, 'Stephen King', 'Frank Darabont', 7);

INSERT INTO mytabs.tab3 (movie_id, actor_name, role) VALUES
    (1, 'Leonardo DiCaprio', 'Cobb'),
    (1, 'Joseph Gordon-Levitt', 'Arthur'),
    (2, 'Christian Bale', 'Bruce Wayne / Batman'),
    (2, 'Heath Ledger', 'Joker'),
    (3, 'Marlon Brando', 'Don Vito Corleone'),
    (3, 'Al Pacino', 'Michael Corleone'),
    (4, 'John Travolta', 'Vincent Vega'),
    (4, 'Uma Thurman', 'Mia Wallace'),
    (5, 'Edward Norton', 'The Narrator'),
    (5, 'Brad Pitt', 'Tyler Durden'),
    (6, 'Tom Hanks', 'Forrest Gump'),
    (6, 'Robin Wright', 'Jenny Curran'),
    (7, 'Tim Robbins', 'Andy Dufresne'),
    (7, 'Morgan Freeman', 'Ellis Boyd "Red" Redding');

-- Создание схемы и представлений
CREATE SCHEMA IF NOT EXISTS myviews;

-- Удаление материализованных представлений, если они существуют
DROP MATERIALIZED VIEW IF EXISTS myviews.view1;
DROP MATERIALIZED VIEW IF EXISTS myviews.view2;
DROP MATERIALIZED VIEW IF EXISTS myviews.view3;
DROP MATERIALIZED VIEW IF EXISTS myviews.view4;
DROP MATERIALIZED VIEW IF EXISTS myviews.view5;

-- Материализованное представление 1: Найти режиссера с наибольшим числом премий
CREATE MATERIALIZED VIEW myviews.view1 AS
SELECT director
FROM mytabs.tab2
GROUP BY director
ORDER BY SUM(awards_count) DESC
LIMIT 1;

-- Материализованное представление 2: Найти все роли указанного актера
CREATE MATERIALIZED VIEW myviews.view2 AS
SELECT actor_name, role
FROM mytabs.tab3
WHERE actor_name = 'Leonardo DiCaprio';

-- Материализованное представление 3: Найти все фильмы, снятые на одной киностудии, одним и тем же режиссером
CREATE MATERIALIZED VIEW myviews.view3 AS
SELECT t1.movie_title, t1.studio, t2.director
FROM mytabs.tab1 t1
JOIN mytabs.tab2 t2 ON t1.id = t2.movie_id
GROUP BY t1.movie_title, t1.studio, t2.director
HAVING COUNT(DISTINCT t2.director) = 1;

-- Материализованное представление 4: Найти актеров, снимавшихся на одной киностудии
CREATE MATERIALIZED VIEW myviews.view4 AS
SELECT t3.actor_name, t1.studio
FROM mytabs.tab1 t1
JOIN mytabs.tab3 t3 ON t1.id = t3.movie_id
GROUP BY t3.actor_name, t1.studio
HAVING COUNT(DISTINCT t3.actor_name) > 1;

-- Материализованное представление 5: Найти всех актеров, снимавшихся в фильмах определенного сценариста
CREATE MATERIALIZED VIEW myviews.view5 AS
SELECT DISTINCT t3.actor_name, t2.screenplay_author
FROM mytabs.tab3 t3
JOIN mytabs.tab2 t2 ON t3.movie_id = t2.movie_id
WHERE t2.screenplay_author = 'Quentin Tarantino';
