USE laura;

SET SQL_SAFE_UPDATES=0;
-- stack overflow to disable error 1175 using safe update mode

DROP TABLE schoolSalary, schools, degreeSalary; 

CREATE TABLE schoolSalary (
	school VARCHAR(80), 
    region VARCHAR(30) CHECK (region IN ('Northeastern', 'Southern', 'Western', 'Midwestern', 'California')) NOT NULL,
    starting_median DECIMAL,
    mid_career_median DECIMAL, 
	mid_career_90 DECIMAL,
    PRIMARY KEY(school)
	);
    
CREATE TABLE schools (
	school VARCHAR(80) REFERENCES schoolSalary(school), 
    conference VARCHAR(30) CHECK (conference IN ('Patriot', 'Pac-12', 'SEC', 'Big 12', 'ACC', 'Big Ten', 'Independent'))
);

CREATE TABLE degreeSalary (
	degree VARCHAR(50) PRIMARY KEY, 
    starting_median DECIMAL,
    mid_career_median DECIMAL,
    mid_career_90 DECIMAL
);

UPDATE schools_src
SET school = "University of Notre Dame"
WHERE school = "Notre Dame";

UPDATE schools_src
SET school = "Rutgers University"
WHERE school = "Rutgers";

INSERT INTO schools(school, conference)
SELECT school_salary_src.school, schools_src.conference
FROM schools_src
RIGHT JOIN school_salary_src
ON school_salary_src.school = schools_src.school;
-- 327 rows returned


UPDATE school_salary_src
SET starting_median = REPLACE(starting_median,'$',''), 
mid_career_median = REPLACE(mid_career_median,'$',''),
mid_career_90 = REPLACE(mid_career_90,'$','');

UPDATE school_salary_src
SET starting_median = REPLACE(starting_median,',',''), 
mid_career_median = REPLACE(mid_career_median,',',''),
mid_career_90 = REPLACE(mid_career_90,',','');

UPDATE school_salary_src
SET starting_median = NULL
WHERE starting_median = '';

UPDATE school_salary_src
SET mid_career_median = NULL
WHERE mid_career_median = '';

UPDATE school_salary_src
SET mid_career_90 = NULL
WHERE mid_career_90 = '';

INSERT INTO schoolSalary
SELECT school, region, starting_median, mid_career_median, mid_career_90
FROM school_salary_src;
-- 327 rows returned

 
UPDATE degree_salary_src
SET starting_median_salary = REPLACE(starting_median_salary,'$',''), 
mid_career_median_salary = REPLACE(mid_career_median_salary,'$',''),
mid_career_90th_percentile_salary = REPLACE(mid_career_90th_percentile_salary,'$','')
;

UPDATE degree_salary_src
SET starting_median_salary = REPLACE(starting_median_salary,',',''), 
mid_career_median_salary = REPLACE(mid_career_median_salary,',',''),
mid_career_90th_percentile_salary = REPLACE(mid_career_90th_percentile_salary,',','')
;

INSERT INTO degreeSalary 
SELECT degree, starting_median_salary, mid_career_median_salary, mid_career_90th_percentile_salary
FROM degree_salary_src;
-- 50 rows returned


SELECT *
FROM schoolSalary
WHERE school like '%tech%'
ORDER BY starting_median DESC;
-- 16 rows returned


SELECT *
FROM degreeSalary
WHERE degreeSalary.mid_career_90 = (SELECT MAX(mid_career_90) FROM degreesalary);
-- 1 row returned


SELECT schools.school, starting_median, mid_career_median, mid_career_90
FROM schoolSalary
JOIN schools
ON schools.school = schoolSalary.school 
WHERE conference = 'Big Ten'
ORDER BY mid_career_90 DESC;
-- 14 rows returned


SELECT school, CONCAT('$', FORMAT(starting_median, 2)) AS starting_median, 
CONCAT('$', FORMAT(mid_career_median, 2)) AS mid_career_median, CONCAT('$', FORMAT(mid_career_90, 2)) AS mid_career_90
FROM schoolSalary
WHERE school ='Fairleigh Dickinson University' OR school ='Princeton University' OR school ='Rider University'
 OR school ='Rutgers University' OR school ='Seton Hall University' OR school ='Stevens Institute of Technology'
ORDER BY school;
-- 6 rows returned


SELECT degree, CONCAT('$', FORMAT(starting_median, 2)) AS starting_median
FROM degreeSalary
WHERE degree like '%information%' OR degree like '%marketing%' OR degree like '%accounting%'
 OR degree like '%finance%' OR degree like '%business%'
ORDER BY starting_median DESC;
-- 6 rows returned


SELECT schoolSalary.school, CONCAT('$', FORMAT(starting_median, 2)) AS starting_median
FROM schoolSalary
LEFT JOIN schools
ON schoolSalary.school = schools.school
WHERE conference = 'Big Ten' AND starting_median > 49200
ORDER BY starting_median DESC;
-- 6 rows returned


SELECT schools.school, conference, region,  CONCAT('$', FORMAT(starting_median, 2)) AS starting_median,
  	CASE
		WHEN mid_career_median IS NULL AND mid_career_90 IS NULL THEN 'TRUE'
        ELSE 'FALSE'
	END AS both_mid_career_unknown
FROM schoolSalary
JOIN schools
ON schoolsalary.school = schools.school
WHERE mid_career_90 IS NULL
ORDER BY conference, school;
-- 54 rows returned


SELECT school, starting_median, mid_career_median, 
CONCAT(ROUND(((mid_career_median - starting_median)/starting_median)*100), '%') AS percent_incr
FROM schoolSalary
ORDER BY (((mid_career_median - starting_median)/starting_median)*100) DESC; 
