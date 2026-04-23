-- NETFLIX DATA ANALYSIS PROJECT 
create database netflix;
use netflix;

-- Create Table
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix (
    show_id VARCHAR(10),
    type VARCHAR(20),
    title VARCHAR(250),
    director VARCHAR(550),
    casts VARCHAR(1000),
    country VARCHAR(250),
    date_added VARCHAR(50),
    release_year INT,
    rating VARCHAR(20),
    duration VARCHAR(20),
    listed_in VARCHAR(250),
    description VARCHAR(550)
);

SELECT * FROM netflix;

-- 1. Count number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS total_content
FROM netflix
GROUP BY type;

-- 2. Most common rating for Movies and TV Shows
SELECT type, rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix
    GROUP BY type, rating
) t
WHERE ranking = 1;

-- 3. List all movies released in 2020
SELECT *
FROM netflix
WHERE release_year = 2020
AND type = 'Movie';

-- 4. Top 5 countries with most content
SELECT 
    country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Content added in last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added,'%M %d, %Y') 
>= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);

-- 7. Movies / Shows by director Rajiv Chilaka
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. TV Shows with more than 5 seasons
SELECT *
FROM netflix
WHERE type='TV Show'
AND CAST(SUBSTRING_INDEX(duration,' ',1) AS UNSIGNED) > 5;

-- 9. Count content items in each genre
SELECT 
    listed_in AS genre,
    COUNT(*) AS total_content
FROM netflix
GROUP BY listed_in
ORDER BY total_content DESC;

-- 10. Average content release by India (Top 5 years)
SELECT 
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id) /
        (SELECT COUNT(show_id) FROM netflix WHERE country='India') * 100,
        2
    ) AS avg_release
FROM netflix
WHERE country='India'
GROUP BY release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. Movies that are Documentaries
SELECT *
FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- 12. Content without director
SELECT *
FROM netflix
WHERE director IS NULL OR director = '';

-- 13. Movies Salman Khan appeared in last 10 years
SELECT *
FROM netflix
WHERE casts LIKE '%Salman Khan%'
AND release_year >= YEAR(CURDATE()) - 10;

-- 14. Top 10 actors in movies produced in India
SELECT 
    casts AS actor,
    COUNT(*) AS movie_count
FROM netflix
WHERE country='India'
GROUP BY casts
ORDER BY movie_count DESC
LIMIT 10;

-- 15. Categorize content as Good or Bad
SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT 
        *,
        CASE
            WHEN description LIKE '%kill%' 
              OR description LIKE '%violence%' 
            THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) t
GROUP BY category, type
ORDER BY type;