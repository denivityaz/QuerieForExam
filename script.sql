-- Создание ENUM для ролей членов семьи
CREATE TYPE Role AS ENUM ('Husband', 'Wife', 'Son', 'Daughter');

-- Создание таблицы "Семьи"
CREATE TABLE Families (
    family_id SERIAL PRIMARY KEY,
    family_name VARCHAR(100) NOT NULL
);

-- Создание таблицы "Члены семьи"
CREATE TABLE FamilyMembers (
    member_id SERIAL PRIMARY KEY,
    family_id INT REFERENCES Families(family_id),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    gender CHAR(1) NOT NULL CHECK (gender IN ('M', 'F')),
    date_of_birth DATE NOT NULL,
    is_twin BOOLEAN NOT NULL DEFAULT FALSE,
    role_type Role NOT NULL
);

-- Создание таблицы "Отношения"
CREATE TABLE Relationships (
    relationship_id SERIAL PRIMARY KEY,
    member1_id INT REFERENCES FamilyMembers(member_id),
    member2_id INT REFERENCES FamilyMembers(member_id),
    relationship_type VARCHAR(50) NOT NULL,
    CONSTRAINT unique_relationship UNIQUE (member1_id, member2_id),
    CONSTRAINT no_bigamy CHECK (
        NOT EXISTS (
            SELECT 1 FROM Relationships r
            WHERE (r.member1_id = member1_id OR r.member2_id = member1_id)
              AND r.relationship_type = 'Spouse'
        ) AND
        NOT EXISTS (
            SELECT 1 FROM Relationships r
            WHERE (r.member1_id = member2_id OR r.member2_id = member2_id)
              AND r.relationship_type = 'Spouse'
        )
    )
);

-- Примеры вставки данных
-- Вставка семей
INSERT INTO Families (family_name) VALUES ('Ивановы'), ('Петровы');

-- Вставка членов семьи
INSERT INTO FamilyMembers (family_id, first_name, last_name, gender, date_of_birth, is_twin, role_type)
VALUES
    (1, 'Иван', 'Иванов', 'M', '1975-01-01', FALSE, 'Husband'),
    (1, 'Мария', 'Иванова', 'F', '1980-05-05', FALSE, 'Wife'),
    (1, 'Петр', 'Иванов', 'M', '2000-10-10', FALSE, 'Son'),
    (1, 'Анна', 'Иванова', 'F', '2005-12-12', FALSE, 'Daughter'),
    (2, 'Алексей', 'Петров', 'M', '1982-03-15', FALSE, 'Husband'),
    (2, 'Екатерина', 'Петрова', 'F', '1985-07-20', FALSE, 'Wife'),
    (2, 'Иван', 'Петров', 'M', '2010-11-25', FALSE, 'Son'),
    (2, 'Мария', 'Петрова', 'F', '2015-09-30', FALSE, 'Daughter');

-- Вставка отношений
INSERT INTO Relationships (member1_id, member2_id, relationship_type)
VALUES
    (1, 2, 'Spouse'),  -- Иван и Мария - супруги
    (1, 3, 'Parent'),  -- Иван - отец Петра
    (2, 3, 'Parent'),  -- Мария - мать Петра
    (1, 4, 'Parent'),  -- Иван - отец Анны
    (2, 4, 'Parent'),  -- Мария - мать Анны
    (5, 6, 'Spouse'),  -- Алексей и Екатерина - супруги
    (5, 7, 'Parent'),  -- Алексей - отец Ивана
    (6, 7, 'Parent'),  -- Екатерина - мать Ивана
    (5, 8, 'Parent'),  -- Алексей - отец Марии
    (6, 8, 'Parent');  -- Екатерина - мать Марии
