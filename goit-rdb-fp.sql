-- task # 1
CREATE SCHEMA IF NOT EXISTS pandemic;
USE pandemic;

SELECT * FROM infectious_cases LIMIT 20;

-- task # 2
DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    id     INT AUTO_INCREMENT PRIMARY KEY,
    entity VARCHAR(255) NOT NULL,
    code   VARCHAR(20),
    UNIQUE KEY uq_entity_code (entity, code)
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

CREATE TABLE infectious_cases_normalized AS
SELECT
    e.id AS entity_id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e ON e.Entity = ic.Entity AND e.Code = ic.Code;

ALTER TABLE infectious_cases_normalized
    ADD id INT AUTO_INCREMENT PRIMARY KEY FIRST,
    ADD FOREIGN KEY (entity_id) REFERENCES entities (id);
    
SELECT COUNT(*) FROM infectious_cases;
SELECT COUNT(*) FROM infectious_cases_normalized;
SELECT COUNT(*) FROM entities;

-- task # 3
SELECT
    e.id,
    e.Entity,
    e.Code,
    AVG(CAST(n.Number_rabies AS DOUBLE)) AS avg_rabies,
    MIN(CAST(n.Number_rabies AS DOUBLE)) AS min_rabies,
    MAX(CAST(n.Number_rabies AS DOUBLE)) AS max_rabies,
    SUM(CAST(n.Number_rabies AS DOUBLE)) AS sum_rabies
FROM infectious_cases_normalized n
JOIN entities e ON e.id = n.entity_id
WHERE n.Number_rabies <> ''
GROUP BY e.id, e.Entity, e.Code
ORDER BY avg_rabies DESC
LIMIT 10;

-- task #4	
SELECT
    id,
    Year,
    MAKEDATE(Year, 1)                                 AS year_start,
    CURDATE()                                         AS today,
    TIMESTAMPDIFF(YEAR, MAKEDATE(Year, 1), CURDATE()) AS years_diff
FROM infectious_cases_normalized;


-- task #5
DROP FUNCTION IF EXISTS years_since;

DELIMITER //

CREATE FUNCTION years_since(input_year INT)
RETURNS INT
NO SQL
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, MAKEDATE(input_year, 1), CURDATE());
END //

DELIMITER ;

SELECT
    id,
    Year,
    years_since(Year) AS years_diff
FROM infectious_cases_normalized;