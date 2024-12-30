# Netflix_first_project

![Netflix Logo](https://github.com/Kez123man/Netflix_first_project/blob/main/Couleur-logo-Netflix-3668402216.jpg)

## Overview
This SQL project involves a comprehensive analysis of Netflix's movies and TV shows data. The goal of the project is to extract valuable business insights and answer questions based on the dataset. The following README provides an account of the project's objectives, business problems, solutions, analysis, and conclusion.

## Objectives
1. To analyse the distribution of content types (the number of movies and TV shows).
2. To identify the most common ratings for movies and TV shows.
3. List and analyse the content based on countries, their durations, etc.
4. Explore and categorise content based on specific criteria and keywords.

## Dataset
The data for this SQL project is sourced from the Kaggle dataset below:

Dataset Link: [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema 
-- Netflix Project
```sql
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
```

-- 15 Business Problems

-- 1. Count the number of Movies vs TV shows

```sql
SELECT 
type,
COUNT (*) as total_content
FROM netflix
GROUP BY type;
```

Objective: Find the overall distribution of content types (TV shows and movies) on Netflix.

-- 2. Find the most common rating for movies and tv shows
```sql
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
```

-- 3. List all the movies released in the 1990s

```sql
SELECT release_year
FROM netflix
WHERE release_year >= 1990 AND release_year < 2000;
```

-- 4. Find the 10 countries with the most content on Netflix

```sql
SELECT 
UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
COUNT (*) as overall_content
FROM Netflix
GROUP BY country
ORDER BY overall_content DESC
LIMIT 10;
```

-- 5. Find the longest film

```sql
SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix)
```

-- 6. Find all the content added in the last fifteen years

```sql
SELECT *
FROM netflix
WHERE 
    TO_DATE(date_added, 'DD/MM/YYYY') >= CURRENT_DATE - INTERVAL '15 years';
```

-- 7. Find all the movies/tv shows directed by 'Steven Spielberg' that came out before the year 2000.

```sql
SELECT *
FROM netflix
WHERE director LIKE '%Steven Spielberg%' AND release_year <= 2000;
```

-- 8. Find all the tv shows with more than 7 seasons.

```sql
SELECT 
	*	
FROM netflix
WHERE
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 7
```

-- 9. Count the number of content items in each genre.	

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
```

-- 10. Find rach year and average cotent release by France on Neflix and return the top 3 years with the highest average content release.

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(date_added, 'DD-MM-YYYY')) as year,
	COUNT(*),
	ROUND(
	COUNT(*)::numeric /(SELECT COUNT(*) FROM netflix WHERE country = 'France')::numeric * 100
	,2)as avg_con_per_annum
FROM netflix
WHERE country = 'France'
GROUP BY 1
```

-- 11. List all tv shows that are international shows. 

```sql
SELECT * FROM netflix
WHERE 
	listed_in ILIKE '%International TV Shows'
```

-- 12. Find all the content without a cast.

```sql
SELECT *
	FROM netflix
	WHERE casts IS NULL
```

-- 13. How many movies has 'Denzel Washington' appeared in the last 5 years?
```sql
SELECT *
	FROM netflix
	WHERE 
	casts ILIKE '%Denzel Washington%'
	AND
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 5
```
-- 14. Find the top 5 actors who have appeared in the highest number of movies produced in France.

```sql
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
```
-- 15. Categorise the content based on the presence of the the keywords 'fight' and 'battle in the description field. Label this content as 'bad' and the rest as 'good'.
Additionally, count the number of items in each category. 

```sql
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
```


## Analysis and Conclusion
Content Distribution: The dataset contains a diverse range of movies and TV shows, although the number of movies outnumber the number of tv shows almost 3:1.
Common Ratings: Finding the most common TV and movie ratings can help provide an understanding of Netflix's target audience.
Geographical Insights: The top countries demomstrate India as a large market that Netflix can continue to target.
Content Categorisation: Categorising content based on specific keywords such as 'fight' and 'battle' helps one understand the nature of the content available.
The analysis provided helps create a comprehensive view of Netflix's content and can help inform business strategy and the company's decision-making.
