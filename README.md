# Netflix Movies and TV Shows Data Analysis Using SQL

![Netflix Logo](https://github.com/GT-Creat0r/Netflix-SQL-Project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset.

## Objectives
- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:
- **Dataset Link:** [Netflix Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```sql
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

```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows.
**Objective:** Determine the distribution of content types on Netflix.
```sql
SELECT 
	type,
	COUNT(*)
FROM netflix
GROUP BY type;
```
### 2. Find the Most Common Rating for Movies and TV Shows.
**Objective:** Identify the most frequently occurring rating for each type of content.
```sql
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
```

### 3. List All Movies Released in a Specific Year (e.g., 2020).
**Objective:** Retrieve all movies released in a specific year.
```sql
SELECT *
FROM netflix
WHERE type='Movie'
	AND release_year=2020;
```
### 4. Find the Top 5 Countries with the Most Content on Netflix.
**Objective:** Identify the top 5 countries with the highest number of content items.
```sql
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
```

### 5. Identify the Longest Movie.
**Objective:** Find the movie with the longest duration.
```sql
SELECT *
FROM netflix
WHERE type='Movie' AND duration IS NOT NULL
ORDER BY SPLIT_PART(duration,' ',1)::INT DESC
LIMIT 1;;
```

### 6. Find Content Added in the Last 5 Years.
**Objective:** Retrieve content added to Netflix in the last 5 years.
```sql
SELECT *
FROM netflix
WHERE date_added::DATE >= CURRENT_DATE - INTERVAL '5 years';
```

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'.
**Objective:** List all content directed by 'Rajiv Chilaka'.
```sql
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';
```
### 8. List All TV Shows with More Than 5 Seasons.
**Objective:** Identify TV shows with more than 5 seasons.
```sql
SELECT *
FROM netflix
WHERE type='TV Show'
	AND SPLIT_PART(duration,' ',1)::INT >5;
```
### 9. Count the Number of Content Items in Each Genre.
**Objective:** Count the number of content items in each genre.
```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(listed_in,''),','))) AS genre,
	COUNT(*) AS no_of_content
FROM netflix
GROUP BY 1;
```

### 10.Find each year and the average numbers of content release in India on netflix.
**Objective:** Calculate the average number of content releases by India in each year.
```sql
SELECT release_year,
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(country,''),','))) AS country,
	COUNT(show_id) AS total_release,
	ROUND(COUNT(show_id):: NUMERIC/(SELECT COUNT(show_id) FROM netflix WHERE country='India')::NUMERIC *100,2) AS avg_release
FROM netflix
WHERE country='India'
GROUP BY 1,2
ORDER BY 4 DESC;
```
### 11. List All Movies that are Documentaries.
**Objective:** Retrieve all movies classified as documentaries.
```sql
SELECT *
FROM netflix
WHERE type='Movie'
 AND 
 listed_in ILIKE '%documentaries%';
```

### 12. Find All Content Without a Director.
**Objective:** List content that does not have a director.
```sql
SELECT *
FROM netflix
WHERE director IS NULL;
```

### 13.Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years.
**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.
```sql
SELECT * 
FROM netflix
WHERE 
	type='Movie'
	AND casts LIKE '%Salman Khan%'
 	AND release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India.
**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.
```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(COALESCE(casts,''),','))) AS actors,
	COUNT(show_id) AS movies_played_in
FROM netflix
WHERE country = 'India'
GROUP BY actors
ORDER BY 2 DESC
LIMIT 10;
```

### 15. Categorize the Content Based on the Presence of 'kill' and 'violence' Keywords in the description field. Label content containing these keywords as 'Bad Content' and all other content as 'Good Content'. Count how many items fall into each category.
**Objective:** Categorize content as 'Bad Content' if it contains 'kill' or 'violence' and 'Good Content' otherwise. Count the number of items in each category.
```sql
WITH label_category AS(
SELECT *,
	CASE 
		WHEN (description LIKE '%kill%' OR description LIKE '%violence%') THEN 'Bad Content'
		ELSE 'Good Content'
	END AS category			
FROM netflix
)
SELECT  category, 
		COUNT(*) AS content_count
FROM label_category
GROUP BY category;
```

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.









