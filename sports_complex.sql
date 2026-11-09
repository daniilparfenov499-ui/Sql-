PRAGMA foreign_keys = ON;

-- ============================================================
-- 1. ТАБЛИЦЫ
-- ============================================================

CREATE TABLE athletes (
    athlete_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    date_of_birth DATE NOT NULL,
    gender TEXT CHECK(gender IN ('М', 'Ж')),
    height DECIMAL(5,2),
    weight DECIMAL(6,2),
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status TEXT DEFAULT 'активный' CHECK(status IN ('активный', 'травма', 'отстранен', 'неактивный')),
    notes TEXT
);

CREATE TABLE sports (
    sport_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    type TEXT CHECK(type IN ('индивидуальный', 'командный', 'парный')),
    is_active BOOLEAN DEFAULT 1
);

CREATE TABLE facilities (
    facility_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('зал', 'бассейн', 'поле', 'корт', 'стадион', 'ледовая арена')),
    capacity INTEGER,
    area DECIMAL(8,2),
    sport_id INTEGER,
    is_available BOOLEAN DEFAULT 1,
    description TEXT,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

CREATE TABLE coaches (
    coach_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT UNIQUE,
    specialization TEXT,
    qualification_level TEXT CHECK(qualification_level IN ('любитель', 'кандидат в мастера', 'мастер спорта', 'international')),
    hire_date DATE NOT NULL,
    fire_date DATE,
    salary DECIMAL(10,2),
    status TEXT DEFAULT 'активный' CHECK(status IN ('активный', 'неактивный')),
    notes TEXT
);

CREATE TABLE teams (
    team_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    sport_id INTEGER NOT NULL,
    coach_id INTEGER,
    founded_date DATE,
    status TEXT DEFAULT 'активная' CHECK(status IN ('активная', 'расформирована', 'в процессе')),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    FOREIGN KEY (coach_id) REFERENCES coaches(coach_id)
);

CREATE TABLE team_athletes (
    team_athlete_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER NOT NULL,
    athlete_id INTEGER NOT NULL,
    position TEXT,
    jersey_number INTEGER,
    join_date DATE NOT NULL,
    leave_date DATE,
    status TEXT DEFAULT 'активный',
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id),
    UNIQUE(team_id, athlete_id)
);

CREATE TABLE memberships (
    membership_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    duration_days INTEGER NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    sport_id INTEGER,
    max_visits_per_week INTEGER,
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

CREATE TABLE subscriptions (
    subscription_id INTEGER PRIMARY KEY AUTOINCREMENT,
    athlete_id INTEGER NOT NULL,
    membership_id INTEGER NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    payment_date DATETIME NOT NULL,
    paid_amount DECIMAL(10,2) NOT NULL,
    status TEXT DEFAULT 'активная' CHECK(status IN ('активная', 'истекла', 'заморожена', 'отменена')),
    notes TEXT,
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (membership_id) REFERENCES memberships(membership_id)
);

CREATE TABLE competitions (
    competition_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    sport_id INTEGER NOT NULL,
    level TEXT CHECK(level IN ('любительский', 'районный', 'городской', 'региональный', 'всероссийский', 'международный')),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    location TEXT,
    format TEXT CHECK(format IN ('круговая система', 'выбывание', 'смешанная')),
    status TEXT DEFAULT 'планирование' CHECK(status IN ('планирование', 'регистрация', 'в процессе', 'завершено', 'отмена')),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

CREATE TABLE matches (
    match_id INTEGER PRIMARY KEY AUTOINCREMENT,
    competition_id INTEGER NOT NULL,
    sport_id INTEGER NOT NULL,
    team1_id INTEGER,
    team2_id INTEGER,
    athlete1_id INTEGER,
    athlete2_id INTEGER,
    match_date DATETIME NOT NULL,
    facility_id INTEGER,
    team1_score INTEGER,
    team2_score INTEGER,
    result TEXT CHECK(result IN ('победа 1', 'победа 2', 'ничья', 'отмена')),
    status TEXT DEFAULT 'запланирован' CHECK(status IN ('запланирован', 'в процессе', 'завершен', 'отмена')),
    notes TEXT,
    FOREIGN KEY (competition_id) REFERENCES competitions(competition_id),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    FOREIGN KEY (team1_id) REFERENCES teams(team_id),
    FOREIGN KEY (team2_id) REFERENCES teams(team_id),
    FOREIGN KEY (athlete1_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (athlete2_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

CREATE TABLE training_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    team_id INTEGER,
    athlete_id INTEGER,
    coach_id INTEGER NOT NULL,
    sport_id INTEGER NOT NULL,
    session_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    facility_id INTEGER,
    duration_minutes INTEGER,
    type TEXT CHECK(type IN ('техника', 'физическая подготовка', 'тактика', 'общая')),
    attendance_count INTEGER,
    notes TEXT,
    FOREIGN KEY (team_id) REFERENCES teams(team_id),
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (coach_id) REFERENCES coaches(coach_id),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id)
);

CREATE TABLE athlete_performances (
    performance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    athlete_id INTEGER NOT NULL,
    match_id INTEGER,
    competition_id INTEGER,
    sport_id INTEGER NOT NULL,
    performance_date DATE NOT NULL,
    score DECIMAL(8,2),
    time TIME,
    distance DECIMAL(8,2),
    result TEXT,
    achievement_level TEXT CHECK(achievement_level IN ('отличное', 'хорошее', 'среднее', 'плохое')),
    notes TEXT,
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id),
    FOREIGN KEY (competition_id) REFERENCES competitions(competition_id),
    FOREIGN KEY (sport_id) REFERENCES sports(sport_id)
);

CREATE TABLE injuries (
    injury_id INTEGER PRIMARY KEY AUTOINCREMENT,
    athlete_id INTEGER NOT NULL,
    injury_date DATE NOT NULL,
    type TEXT NOT NULL,
    severity TEXT CHECK(severity IN ('легкая', 'средняя', 'тяжелая')),
    description TEXT,
    recovery_date DATE,
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    athlete_id INTEGER,
    team_id INTEGER,
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(10,2) NOT NULL,
    payment_type TEXT CHECK(payment_type IN ('подписка', 'членский взнос', 'услуга', 'штраф')),
    payment_method TEXT CHECK(payment_method IN ('наличные', 'карта', 'переводом')),
    status TEXT DEFAULT 'успешно' CHECK(status IN ('успешно', 'ожидание', 'отклонено')),
    invoice_number TEXT UNIQUE,
    notes TEXT,
    FOREIGN KEY (athlete_id) REFERENCES athletes(athlete_id),
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

CREATE TABLE staff (
    staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
    full_name TEXT NOT NULL,
    phone TEXT,
    email TEXT UNIQUE,
    position TEXT CHECK(position IN ('администратор', 'администратор зала', 'врач', 'массажист', 'техник')),
    hire_date DATE NOT NULL,
    fire_date DATE,
    salary DECIMAL(10,2),
    status TEXT DEFAULT 'активный' CHECK(status IN ('активный', 'неактивный')),
    notes TEXT
);

CREATE TABLE events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    event_type TEXT CHECK(event_type IN ('соревнование', 'открытый урок', 'мастер-класс', 'праздник спорта')),
    event_date DATETIME NOT NULL,
    facility_id INTEGER,
    organizer_id INTEGER,
    expected_participants INTEGER,
    status TEXT DEFAULT 'планирование' CHECK(status IN ('планирование', 'регистрация', 'проведение', 'завершено')),
    FOREIGN KEY (facility_id) REFERENCES facilities(facility_id),
    FOREIGN KEY (organizer_id) REFERENCES staff(staff_id)
);

-- ============================================================
-- 2. ИНДЕКСЫ (всего 25 штук)
-- ============================================================

CREATE INDEX idx_athletes_phone ON athletes(phone);
CREATE INDEX idx_athletes_email ON athletes(email);
CREATE INDEX idx_athletes_status ON athletes(status);
CREATE INDEX idx_team_athletes_team ON team_athletes(team_id);
CREATE INDEX idx_team_athletes_athlete ON team_athletes(athlete_id);
CREATE INDEX idx_subscriptions_athlete ON subscriptions(athlete_id);
CREATE INDEX idx_subscriptions_end_date ON subscriptions(end_date);
CREATE INDEX idx_matches_competition ON matches(competition_id);
CREATE INDEX idx_matches_date ON matches(match_date);
CREATE INDEX idx_matches_team1 ON matches(team1_id);
CREATE INDEX idx_matches_team2 ON matches(team2_id);
CREATE INDEX idx_training_sessions_coach ON training_sessions(coach_id);
CREATE INDEX idx_training_sessions_date ON training_sessions(session_date);
CREATE INDEX idx_training_sessions_team ON training_sessions(team_id);
CREATE INDEX idx_training_sessions_facility ON training_sessions(facility_id);
CREATE INDEX idx_athlete_performances_athlete ON athlete_performances(athlete_id);
CREATE INDEX idx_athlete_performances_date ON athlete_performances(performance_date);
CREATE INDEX idx_injuries_athlete ON injuries(athlete_id);
CREATE INDEX idx_injuries_date ON injuries(injury_date);
CREATE INDEX idx_payments_athlete ON payments(athlete_id);
CREATE INDEX idx_payments_date ON payments(payment_date);
CREATE INDEX idx_competitions_sport ON competitions(sport_id);
CREATE INDEX idx_competitions_date ON competitions(start_date);
CREATE INDEX idx_teams_sport ON teams(sport_id);
CREATE INDEX idx_facilities_sport ON facilities(sport_id);

-- ============================================================
-- 3. ПРЕДСТАВЛЕНИЯ (VIEWS)
-- ============================================================

CREATE VIEW v_active_subscriptions AS
SELECT s.subscription_id, a.full_name, a.phone, m.name AS membership_type, s.start_date, s.end_date, CAST((JULIANDAY(s.end_date) - JULIANDAY('now')) AS INTEGER) AS days_remaining, m.price
FROM subscriptions s
JOIN athletes a ON s.athlete_id = a.athlete_id
JOIN memberships m ON s.membership_id = m.membership_id
WHERE s.status = 'активная' AND s.end_date >= DATE('now');

CREATE VIEW v_weekly_training_schedule AS
SELECT ts.session_id, ts.session_date, ts.start_time, ts.end_time, c.full_name AS coach, s.name AS sport, f.name AS facility, CASE WHEN t.team_id IS NOT NULL THEN t.name ELSE a.full_name END AS participant, ts.type AS training_type
FROM training_sessions ts
JOIN coaches c ON ts.coach_id = c.coach_id
JOIN sports s ON ts.sport_id = s.sport_id
LEFT JOIN facilities f ON ts.facility_id = f.facility_id
LEFT JOIN teams t ON ts.team_id = t.team_id
LEFT JOIN athletes a ON ts.athlete_id = a.athlete_id
WHERE ts.session_date >= DATE('now')
ORDER BY ts.session_date, ts.start_time;

CREATE VIEW v_competition_results AS
SELECT m.match_id, c.name AS competition, CASE WHEN t1.team_id IS NOT NULL THEN t1.name ELSE a1.full_name END AS team_athlete_1, CASE WHEN t2.team_id IS NOT NULL THEN t2.name ELSE a2.full_name END AS team_athlete_2, m.team1_score, m.team2_score, m.result, f.name AS facility, m.match_date
FROM matches m
JOIN competitions c ON m.competition_id = c.competition_id
LEFT JOIN teams t1 ON m.team1_id = t1.team_id
LEFT JOIN teams t2 ON m.team2_id = t2.team_id
LEFT JOIN athletes a1 ON m.athlete1_id = a1.athlete_id
LEFT JOIN athletes a2 ON m.athlete2_id = a2.athlete_id
LEFT JOIN facilities f ON m.facility_id = f.facility_id
WHERE m.status IN ('в процессе', 'завершен')
ORDER BY m.match_date DESC;

CREATE VIEW v_revenue_summary AS
SELECT DATE(payment_date) AS payment_date, payment_type, COUNT(*) AS transaction_count, SUM(amount) AS total_amount
FROM payments
WHERE status = 'успешно'
GROUP BY DATE(payment_date), payment_type
ORDER BY DATE(payment_date) DESC;

-- ============================================================
-- 4. ТЕСТОВЫЕ ДАННЫЕ
-- ============================================================

INSERT INTO sports (sport_id, name, description, type, is_active) VALUES
(1, 'Баскетбол', 'Командный вид спорта с мячом', 'командный', 1),
(2, 'Волейбол', 'Командный вид спорта через сетку', 'командный', 1),
(3, 'Плавание', 'Индивидуальный вид спорта в воде', 'индивидуальный', 1),
(4, 'Теннис', 'Парный или индивидуальный вид спорта', 'парный', 1),
(5, 'Легкая атлетика', 'Индивидуальный вид спорта', 'индивидуальный', 1),
(6, 'Футбол', 'Командный вид спорта с мячом', 'командный', 1);

INSERT INTO facilities (facility_id, name, type, capacity, area, sport_id, is_available, description) VALUES
(1, 'Спортивный зал №1', 'зал', 500, 800.0, 1, 1, 'Основной зал для баскетбола'),
(2, 'Спортивный зал №2', 'зал', 300, 600.0, 2, 1, 'Зал для волейбола'),
(3, 'Бассейн', 'бассейн', 200, 1250.0, 3, 1, 'Олимпийский бассейн 50м'),
(4, 'Теннисные корты', 'корт', 100, 2000.0, 4, 1, 'Открытые теннисные корты'),
(5, 'Стадион', 'стадион', 5000, 10000.0, 5, 1, 'Легкоатлетический стадион'),
(6, 'Футбольное поле', 'поле', 500, 7000.0, 6, 1, 'Основное футбольное поле');

INSERT INTO coaches (coach_id, full_name, phone, email, specialization, qualification_level, hire_date, salary, status, notes) VALUES
(1, 'Иван Петров', '+7-999-111-1111', 'ivan.coach@example.com', 'Баскетбол', 'мастер спорта', '2015-01-10', 80000.00, 'активный', NULL),
(2, 'Мария Сидорова', '+7-999-222-2222', 'maria.coach@example.com', 'Волейбол', 'мастер спорта', '2016-05-15', 75000.00, 'активный', NULL),
(3, 'Алексей Иванов', '+7-999-333-3333', 'alex.coach@example.com', 'Плавание', 'мастер спорта', '2014-03-20', 85000.00, 'активный', NULL),
(4, 'Елена Коваленко', '+7-999-444-4444', 'elena.coach@example.com', 'Теннис', 'кандидат в мастера', '2017-07-01', 70000.00, 'активный', NULL),
(5, 'Дмитрий Морозов', '+7-999-555-5555', 'dmitry.coach@example.com', 'Легкая атлетика', 'мастер спорта', '2013-09-10', 82000.00, 'активный', NULL),
(6, 'Сергей Футболов', '+7-999-666-7777', 'sergey.coach@example.com', 'Футбол', 'мастер спорта', '2018-02-15', 78000.00, 'активный', NULL);

INSERT INTO teams (team_id, name, sport_id, coach_id, founded_date, status) VALUES
(1, 'Баскетбол Витязи', 1, 1, '2010-01-15', 'активная'),
(2, 'Волейбол Молнии', 2, 2, '2012-03-20', 'активная'),
(3, 'Футбол Звезда', 6, 6, '2008-06-01', 'активная'),
(4, 'Баскетбол Орлы', 1, 1, '2015-05-10', 'активная'),
(5, 'Волейбол Ураган', 2, 2, '2014-09-01', 'активная');

INSERT INTO athletes (athlete_id, full_name, phone, email, date_of_birth, gender, height, weight, status, notes) VALUES
(1, 'Петр Сергеев', '+7-999-666-6666', 'petr@example.com', '1995-05-15', 'М', 185.5, 85.0, 'активный', NULL),
(2, 'Анна Смирнова', '+7-999-777-7777', 'anna@example.com', '1998-03-22', 'Ж', 172.0, 65.0, 'активный', NULL),
(3, 'Илья Волков', '+7-999-888-8888', 'ilya@example.com', '1992-11-03', 'М', 178.0, 75.0, 'активный', NULL),
(4, 'Ольга Кузнецова', '+7-999-999-9999', 'olga@example.com', '1996-07-14', 'Ж', 175.0, 68.0, 'активный', NULL),
(5, 'Сергей Новиков', '+7-999-101-0101', 'sergey@example.com', '1994-02-28', 'М', 182.0, 80.0, 'активный', NULL),
(6, 'Мария Романова', '+7-999-202-0202', 'maria.r@example.com', '1997-09-11', 'Ж', 170.0, 62.0, 'активный', NULL),
(7, 'Владимир Козлов', '+7-999-303-0303', 'vladimir@example.com', '1991-04-19', 'М', 188.0, 90.0, 'активный', NULL),
(8, 'Екатерина Орлова', '+7-999-404-0404', 'ekaterina@example.com', '1999-12-06', 'Ж', 168.0, 58.0, 'активный', NULL);

INSERT INTO team_athletes (team_id, athlete_id, position, jersey_number, join_date, leave_date, status) VALUES
(1, 1, 'Разыгрывающий', 5, '2024-08-15', NULL, 'активный'),
(1, 2, 'Защитник', 8, '2024-08-20', NULL, 'активный'),
(1, 3, 'Центровой', 10, '2024-08-10', NULL, 'активный'),
(2, 4, 'Связующая', 1, '2024-09-01', NULL, 'активный'),
(2, 5, 'Диагональная', 3, '2024-09-05', NULL, 'активный'),
(3, 6, 'Полузащитник', 7, '2024-05-20', NULL, 'активный'),
(3, 7, 'Форвард', 9, '2024-06-01', NULL, 'активный');

INSERT INTO memberships (membership_id, name, description, duration_days, price, sport_id, max_visits_per_week) VALUES
(1, 'Баскетбол месячный', 'Доступ на месяц', 30, 2000.00, 1, 8),
(2, 'Волейбол месячный', 'Доступ на месяц', 30, 2000.00, 2, 8),
(3, 'Плавание месячный', 'Доступ на месяц', 30, 1500.00, 3, 12),
(4, 'Универсальный (3 месяца)', 'Доступ ко всем видам спорта', 90, 4500.00, NULL, NULL),
(5, 'Студенческий', 'Студенческий абонемент со скидкой', 30, 1000.00, NULL, 4);

INSERT INTO subscriptions (athlete_id, membership_id, start_date, end_date, payment_date, paid_amount, status, notes) VALUES
(1, 1, date('now', '-10 days'), date('now', '+20 days'), datetime('now', '-10 days'), 2000.00, 'активная', NULL),
(2, 2, date('now', '-5 days'),  date('now', '+25 days'), datetime('now', '-5 days'),  2000.00, 'активная', NULL),
(3, 3, date('now', '-20 days'), date('now', '+10 days'), datetime('now', '-20 days'), 1500.00, 'активная', NULL),
(4, 4, date('now', '-15 days'), date('now', '+75 days'), datetime('now', '-15 days'), 4500.00, 'активная', NULL),
(5, 5, date('now', '-8 days'),  date('now', '+22 days'), datetime('now', '-8 days'),  1000.00, 'активная', NULL);

INSERT INTO competitions (competition_id, name, sport_id, level, start_date, end_date, location, format, status) VALUES
(1, 'Чемпионат города по баскетболу', 1, 'городской', date('now', '-60 days'), date('now', '+45 days'), 'Спортивный комплекс', 'круговая система', 'в процессе'),
(2, 'Турнир по волейболу', 2, 'районный', date('now', '+20 days'), date('now', '+35 days'), 'Спортивный комплекс', 'выбывание', 'планирование'),
(3, 'Чемпионат по плаванию', 3, 'городской', date('now', '+50 days'), date('now', '+52 days'), 'Бассейн', 'смешанная', 'планирование'),
(4, 'Открытый турнир по теннису', 4, 'районный', date('now', '+60 days'), date('now', '+70 days'), 'Корты', 'круговая система', 'планирование');

INSERT INTO matches (competition_id, sport_id, team1_id, team2_id, match_date, facility_id, team1_score, team2_score, result, status, notes) VALUES
(1, 1, 1, 4, datetime('now', '+35 days'), 1, NULL, NULL, NULL, 'запланирован', NULL),
(1, 1, 1, 4, datetime('now', '-40 days'), 1, 85, 72, 'победа 1', 'завершен', NULL),
(2, 2, 2, 5, datetime('now', '+25 days'), 2, NULL, NULL, NULL, 'запланирован', NULL);

INSERT INTO training_sessions (team_id, coach_id, sport_id, session_date, start_time, end_time, facility_id, type, notes) VALUES
(1, 1, 1, date('now', '+1 days'), '10:00', '12:00', 1, 'техника', 'Работа над тактикой защиты'),
(2, 2, 2, date('now', '+2 days'), '15:00', '17:00', 2, 'физическая подготовка', 'Развитие скорости'),
(NULL, 3, 3, date('now', '+1 days'), '08:00', '10:00', 3, 'техника', 'Технические упражнения в плавании'),
(NULL, 4, 4, date('now', '+3 days'), '16:00', '18:00', 4, 'тактика', 'Подготовка к турниру');

INSERT INTO athlete_performances (athlete_id, sport_id, performance_date, score, result, achievement_level, notes) VALUES
(1, 1, date('now', '-5 days'), 45.5, '1 место', 'отличное', 'Отличный результат'),
(2, 2, date('now', '-10 days'), 38.2, '2 место', 'хорошее', 'Хорошее выступление'),
(3, 3, date('now', '-3 days'), NULL, '1 место', 'отличное', 'Личный рекорд');

INSERT INTO injuries (athlete_id, injury_date, type, severity, description, recovery_date) VALUES
(5, date('now', '-20 days'), 'Растяжение связок', 'средняя', 'Травма правого голеностопа', date('now', '-5 days')),
(7, date('now', '-30 days'), 'Ушиб', 'легкая', 'Ушиб левого плеча', date('now', '-20 days'));

INSERT INTO payments (athlete_id, team_id, payment_date, amount, payment_type, payment_method, status, invoice_number) VALUES
(1,    NULL, datetime('now', '-10 days'), 2000.00, 'подписка',       'карта',    'успешно', 'INV-0001'),
(2,    NULL, datetime('now', '-5 days'),  2000.00, 'подписка',       'карта',    'успешно', 'INV-0002'),
(3,    NULL, datetime('now', '-20 days'), 1500.00, 'подписка',       'карта',    'успешно', 'INV-0003'),
(4,    NULL, datetime('now', '-15 days'), 4500.00, 'подписка',       'переводом','успешно', 'INV-0004'),
(5,    NULL, datetime('now', '-8 days'),  1000.00, 'подписка',       'наличные', 'успешно', 'INV-0005'),
(NULL, 1,    datetime('now', '-10 days'), 5000.00, 'членский взнос', 'наличные', 'успешно', 'INV-0006');

INSERT INTO staff (full_name, phone, email, position, hire_date, salary, status, notes) VALUES
('Александр Иванов', '+7-999-700-0001', 'alex.admin@example.com', 'администратор', '2010-01-01', 60000.00, 'активный', NULL),
('Виктор Сидоров', '+7-999-700-0002', 'victor@example.com', 'администратор зала', '2018-05-15', 40000.00, 'активный', NULL),
('Дмитрий Петров', '+7-999-700-0003', 'dmitry.med@example.com', 'врач', '2015-03-10', 70000.00, 'активный', NULL),
('Анна Кузнецова', '+7-999-700-0004', 'anna.massage@example.com', 'массажист', '2019-06-01', 45000.00, 'активный', NULL);

INSERT INTO events (name, event_type, event_date, facility_id, organizer_id, expected_participants, status) VALUES
('День открытых дверей', 'открытый урок', datetime('now', '+7 days'), 1, 1, 100, 'планирование'),
('Мастер-класс по плаванию', 'мастер-класс', datetime('now', '+14 days'), 3, 3, 30, 'планирование'),
('Праздник спорта', 'праздник спорта', datetime('now', '+21 days'), 5, 2, 200, 'планирование');