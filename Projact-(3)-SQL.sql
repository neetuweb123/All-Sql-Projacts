use covid_19_Analytics;

CREATE TABLE Country (
    country_id INTEGER PRIMARY KEY,
    country_name TEXT NOT NULL,
    continent TEXT
);


CREATE TABLE CovidStats (
    stat_id INTEGER PRIMARY KEY,
    country_id INTEGER,
    date DATE,
    total_cases INTEGER,
    new_cases INTEGER,
    total_deaths INTEGER,
    new_deaths INTEGER,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Testing (
    test_id INTEGER PRIMARY KEY,
    country_id INTEGER,
    date DATE,
    total_tests INTEGER,
    new_tests INTEGER,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);

CREATE TABLE Vaccination (
    vacc_id INTEGER PRIMARY KEY,
    country_id INTEGER,
    date DATE,
    total_vaccinations INTEGER,
    people_vaccinated INTEGER,
    people_fully_vaccinated INTEGER,
    FOREIGN KEY (country_id) REFERENCES Country(country_id)
);
CREATE TABLE temp_country (
    country_id INTEGER,
    country_name TEXT,
    continent TEXT
);

INSERT INTO temp_country VALUES (1, 'India', 'Asia'), (2, 'USA', 'North America');

# 2.Clean and transform data (formatting, nulls)

DELETE FROM CovidStats WHERE country_id IS NULL;
DELETE FROM Testing WHERE country_id IS NULL;
DELETE FROM Vaccination WHERE country_id IS NULL;

# 3.Create necessary tables and constraints.
INSERT INTO Country (country_id, country_name, continent)
SELECT DISTINCT country_id, country_name, continent FROM temp_country;


# 4.Write analytical queries (top countries, daily trends).
SELECT c.country_name, SUM(cs.total_cases) AS total_cases
FROM CovidStats cs
JOIN Country c ON cs.country_id = c.country_id
GROUP BY cs.country_id
ORDER BY total_cases DESC
LIMIT 5;

# 5.Use GROUP BY and window functions for trends.
SELECT
    country_id,
    date,
    new_cases,
    ROUND(AVG(new_cases) OVER (PARTITION BY country_id ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS moving_avg_7_day
FROM CovidStats;

# 6.Export result views and summary report.
CREATE VIEW CountrySummary AS
    SELECT 
        c.country_name,
        MAX(cs.total_cases) AS total_cases,
        MAX(cs.total_deaths) AS total_deaths,
        MAX(v.total_vaccinations) AS total_vaccinations
    FROM
        Country c
            LEFT JOIN
        CovidStats cs ON c.country_id = cs.country_id
            LEFT JOIN
        Vaccination v ON c.country_id = v.country_id
    GROUP BY c.country_id;
