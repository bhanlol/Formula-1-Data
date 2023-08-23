USE formula1;

-- all time winner's circle
SELECT driverId, forename, surname
FROM drivers
WHERE driverId IN (
	SELECT driverId
	FROM driver_standings
	WHERE position = 1
);

-- 2022 average points per race by constructors
WITH points_2022 AS (
	SELECT constructorId, points, raceId
	FROM constructor_standings
	WHERE raceId = 1096
)
SELECT 
	p.constructorId, 
	c.name, 
	(SUM(p.points) / (SELECT COUNT(raceId) FROM races WHERE year = 2022)) AS points_per_race_2022
FROM points_2022 AS p
JOIN constructors AS c
	ON p.constructorId = c.constructorId
JOIN races AS r
	ON p.raceId = r.raceId
WHERE r.year = 2022
GROUP BY p.constructorId, c.name
ORDER BY points_per_race_2022 DESC;

-- top 50 drivers in points all time
SELECT TOP 50
	d.driverId, d.forename, d.surname, d.nationality, SUM(r.points) AS all_time_points
FROM drivers AS d
JOIN results AS r
	ON d.driverId = r.driverId
GROUP BY d.driverId, d.forename, d.surname, d.nationality
ORDER BY SUM(r.points) DESC;

-- top 50 drivers in wins all time
SELECT TOP 50
	d.driverId, d.forename, d.surname, d.nationality, SUM(r.position) AS all_time_wins
FROM drivers AS d
JOIN results AS r
	ON d.driverId = r.driverId
WHERE r.position = 1
GROUP BY d.driverId, d.forename, d.surname, d.nationality
ORDER BY all_time_wins DESC;

-- top 50 drivers in podiums all time
SELECT TOP 50
	d.driverId, d.forename, d.surname, d.nationality, COUNT(r.position) AS all_time_podiums
FROM drivers AS d
JOIN results AS r
	ON d.driverId = r.driverId
WHERE r.position <= 3
GROUP BY d.driverId, d.forename, d.surname, d.nationality
ORDER BY all_time_podiums DESC;

-- most podiums by driver nationality
SELECT d.nationality, COUNT(r.position) AS all_time_podiums
FROM drivers AS d
JOIN results AS r
	ON d.driverId = r.driverId
WHERE r.position <= 3
GROUP BY d.nationality
ORDER BY all_time_podiums DESC;

-- all time points by constructor
SELECT c.name, c.nationality, SUM(cs.points) AS all_time_points
FROM constructors AS c
JOIN constructor_standings AS cs
	ON c.constructorId = cs.constructorId
GROUP BY c.name, c.nationality
ORDER BY all_time_points DESC;

-- count of accidents by grand prix 2013-2022
SELECT c.circuitId, r.name AS grand_prix, c.location, c.country, COUNT(status) AS accident_count
FROM circuits AS c
JOIN races AS r
	ON c.circuitId = r.circuitId
JOIN results AS f
	ON r.raceId = f.raceId
JOIN status AS s
	ON f.statusId = s.statusId
WHERE status = 'Accident'
	AND year BETWEEN 2013 AND 2022
GROUP BY c.circuitId, r.name, c.location, c.country
ORDER BY COUNT(status) DESC;

-- count of collisions by grand prix 2013-2022
SELECT c.circuitId, r.name AS grand_prix, c.location, c.country, COUNT(status) AS collision_count
FROM circuits AS c
JOIN races AS r
	ON c.circuitId = r.circuitId
JOIN results AS f
	ON r.raceId = f.raceId
JOIN status AS s
	ON f.statusId = s.statusId
WHERE status = 'Collision'
	AND year BETWEEN 2013 AND 2022
GROUP BY c.circuitId, r.name, c.location, c.country
ORDER BY COUNT(status) DESC;

-- count of accidents by constructor 2013-2022
SELECT c.constructorId, c.name, COUNT(status) AS accident_count
FROM constructors AS c
JOIN results AS f
	ON c.constructorId = f.constructorId
JOIN status AS s
	ON f.statusId = s.statusId
JOIN races AS r
	ON f.raceId = r.raceId
WHERE status = 'Accident'
	AND year BETWEEN 2013 AND 2022
GROUP BY c.constructorId, c.name
ORDER BY COUNT(status) DESC;

-- count of collisions by constructor 2013-2022
SELECT c.constructorId, c.name, COUNT(status) AS collision_count
FROM constructors AS c
JOIN results AS f
	ON c.constructorId = f.constructorId
JOIN status AS s
	ON f.statusId = s.statusId
JOIN races AS r
	ON f.raceId = r.raceId
WHERE status = 'Collision'
	AND year BETWEEN 2013 AND 2022
GROUP BY c.constructorId, c.name
ORDER BY COUNT(status) DESC;

-- count of accidents by driver 2013-2022
SELECT d.driverId, d.forename, d.surname, COUNT(status) AS accident_count
FROM drivers AS d
JOIN results AS f
	ON d.driverId = f.driverId
JOIN races AS r
	ON f.raceId = r.raceId
JOIN status AS s
	ON f.statusId = s.statusId
WHERE status = 'Accident'
	AND year BETWEEN 2013 AND 2022
GROUP BY d.driverId, d.forename, d.surname
ORDER BY COUNT(status) DESC;

-- count of collisions by driver 2013-2022
SELECT d.driverId, d.forename, d.surname, COUNT(status) AS collision_count
FROM drivers AS d
JOIN results AS f
	ON d.driverId = f.driverId
JOIN races AS r
	ON f.raceId = r.raceId
JOIN status AS s
	ON f.statusId = s.statusId
WHERE status = 'Collision'
	AND year BETWEEN 2013 AND 2022
GROUP BY d.driverId, d.forename, d.surname
ORDER BY COUNT(status) DESC;

-- average pit stop time by constructor 2013-2022
SELECT c.constructorId, c.name, ROUND(AVG(p.milliseconds), 2) AS avg_pit_ms
FROM pit_stops AS p
JOIN drivers AS d
	ON p.driverId = d.driverId
JOIN results AS f
	ON d.driverId = f.driverId
JOIN races AS r
	ON f.raceId = r.raceId
JOIN constructors AS c
	ON f.constructorId = c.constructorId
WHERE year BETWEEN 2018 AND 2022
GROUP BY c.constructorId, c.name
ORDER BY AVG(p.milliseconds);