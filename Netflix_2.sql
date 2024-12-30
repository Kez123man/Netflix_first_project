-- Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
	show_id	VARCHAR(10),
	type VARCHAR(30),	
	title VARCHAR(150),	
	director VARCHAR(300),	
	casts VARCHAR(1000),	
	country	VARCHAR(150),
	date_added VARCHAR(150),	
	release_year INT,	
	rating VARCHAR(200),	
	duration VARCHAR(15),	
	listed_in VARCHAR(100), 	
	description VARCHAR(350)
);

SELECT * FROM netflix;

-- 15 Business Problems

-- 1. Count the number of Movies vs TV shows

SELECT 
type,
COUNT (*) as total_content
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and tv shows
SELECT
	type,
	rating
FROM
(
SELECT 
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
FROM netflix
GROUP BY 1, 2
) as t1
WHERE ranking = 1

-- 3. List all the movies released in the 1990s

SELECT release_year
FROM netflix
WHERE release_year >= 1990 AND release_year < 2000;


-- 4. Find the 10 countries with the most content on Netflix

SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
COUNT (*) as overall_content
FROM Netflix
GROUP BY country
ORDER BY overall_content DESC
LIMIT 10;


-- 5. Find the longest film

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix)

-- 6. Find content added in the last fifteen years

SELECT *
FROM netflix
WHERE 
    TO_DATE(date_added, 'DD/MM/YYYY') >= CURRENT_DATE - INTERVAL '15 years';

-- 7. Find all the movies/tv shows directed by 'Steven Spielberg' that came out before 2000.

SELECT *
FROM netflix
WHERE director LIKE '%Steven Spielberg%' AND release_year <= 2000;

-- 8. Find all the tv shows with more than 7 seasons

SELECT 
	*	
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 7

-- 9. Count the number of content items in each genre	

SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1

-- 10. Find rach year and average cotent release by France on Neflix
-- Return the top 3 years with the highest avg content release.

SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'DD-MM-YYYY')) as year,
	COUNT(*),
	ROUND(
	COUNT(*)::numeric /(SELECT COUNT(*) FROM netflix WHERE country = 'France')::numeric * 100
	,2)as avg_con_per_annum
FROM netflix
WHERE country = 'France'
GROUP BY 1

-- 11. List all tv shows that are international shows 

SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%International TV Shows'

-- 12. Find all the content without a cast

SELECT *
	FROM netflix
	WHERE casts IS NULL
	
-- 13. How many movies has 'Denzel Washington' appeared in the last 5 years?
SELECT *
	FROM netflix
	WHERE 
	casts ILIKE '%Denzel Washington%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 5

-- 14. Find the top 5 actors who have appeared in the highest number of movies produced in France.

SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts, ',')) as actors,
COUNT(*) as total_content
FROM netflix
WHERE country ILIKE '%France%'
GROUP BY 1
ORDER BY 2 DESC 
LIMIT 5

-- 15. Categorise the content based on the presence of the the keywords 'fight' and 'battle
-- in the description field. Label this content as 'bad' and the rest as 'good'.
-- Count the number of items in each category. 

WITH new_table
AS 
(
SELECT *, 
CASE 
WHEN description ILIKE '%fight%' 
OR description ILIKE '%battle%' THEN 'Bad'
ELSE 'Good'
END category
FROM netflix
)
SELECT category,
COUNT(*) as total_content
FROM new_table
GROUP BY 1
