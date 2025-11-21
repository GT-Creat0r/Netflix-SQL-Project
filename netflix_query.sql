--Netflix Project

DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix(
	show_id VARCHAR(10),
	type VARCHAR(15),
	title VARCHAR(150),
	director VARCHAR(215),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(20),
	duration VARCHAR(20),
	listed_in VARCHAR(200),
	description VARCHAR(300)
);

SELECT Count(*) AS total_content
FROM netflix;

SELECT DISTINCT type
FROM netflix;

SELECT * FROM netflix;

--Business Problems and Solutions
--1. Count the Number of Movies vs TV Shows.
SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY type;

--2. Find the Most Common Rating for Movies and TV Shows.
WITH rankedRating 
AS(
	SELECT 
			DISTINCT rating,
			type,
		COUNT(*) AS rating_count,
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS rank
	FROM netflix
	GROUP BY 1,2
)
SELECT *
FROM rankedRating
WHERE rank=1;

--3. List All Movies Released in a Specific Year (e.g., 2020).
SELECT *
FROM netflix
WHERE type='Movie'
	AND release_year=2020;

--4. Find the Top 5 Countries with the Most Content on Netflix.
SELECT * 
FROM
	(SELECT 
		TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(country,''),','))) AS country,
		COUNT(*) AS most_content
	FROM netflix
	GROUP BY 1)
AS t1
WHERE country IS NOT NULL
ORDER BY most_content DESC
LIMIT 5;

--5. Identify the Longest Movie.
SELECT *
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration,' ',1)::INT DESC
LIMIT 1;

--6. Find Content Added in the Last 5 Years.
SELECT *
FROM netflix
WHERE date_added::DATE >= CURRENT_DATE - INTERVAL '5 years';  -- can also use the TO_DATE(date_added,'Month DD, YYYY')

-- -- just for learning puropse
-- SELECT TO_DATE(date_added,'MONTH DD, YYYY')  -- 'Month DD, YYYY' must be in the same format as present in the table.
-- FROM netflix;

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'.
--1 way 
SELECT * 
FROM
	(SELECT *,
		TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(director,''),','))) AS director_name
	FROM netflix
) AS t1
WHERE director_name='Rajiv Chilaka';

--more easy way
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


--8. List All TV Shows with More Than 5 Seasons
SELECT *
FROM netflix
WHERE type='TV Show'
	AND SPLIT_PART(duration,' ',1)::INT >5;

--9. Count the Number of Content Items in Each Genre.
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(listed_in,''),','))) AS genre,
	COUNT(*) AS no_of_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content release in India on netflix.
SELECT release_year,
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(country,''),','))) AS country,
	COUNT(show_id) AS total_release,
	ROUND(COUNT(show_id):: NUMERIC/(SELECT COUNT(show_id) FROM netflix WHERE country='India')::NUMERIC *100,2) AS avg_release
FROM netflix
WHERE country='India'
GROUP BY 1,2
ORDER BY 4 DESC;


--11. List All Movies that are Documentaries
SELECT *
FROM netflix
WHERE type='Movie'
 AND 
 listed_in ILIKE '%documentaries%';


--12. Find All Content Without a Director
SELECT *
FROM netflix
WHERE director IS NULL;

--13.Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * 
FROM netflix
WHERE 
	type='Movie'
	AND casts LIKE '%Salman Khan%'
 	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(casts,''),','))) AS actors,
	COUNT(show_id) AS movies_played_in
FROM netflix
WHERE country = 'India'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;

--15. Categorize the Content Based on the Presence of 'kill' and 'violence' Keywords in the description field.
-- Label content containing these keywords as 'Bad Content' and all other content as 'Good Content'. Count how many items fall into each category.
WITH label_category AS(
SELECT *,
	CASE 
		WHEN (description LIKE '%kill%' OR description LIKE '%violence%') THEN 'Bad Content'
		ELSE 'Good Content'
	END AS category			
FROM netflix
)
SELECT  category, 
		COUNT(*)
FROM label_category
GROUP BY category;


