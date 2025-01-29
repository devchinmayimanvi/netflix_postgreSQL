select *
from netflix

-- 1. Count the number of Movies vs TV Shows

select type,count(*)
from netflix
group by type


-- 2. Find the most common rating for movies and TV shows

with t1 as (
select 
	type, 
	rating, 
	count(*) as count_no,
	rank() over (partition by type order by count(*) desc) as rank_of
from netflix
group by type, rating
order by 1, 3 desc)

select type, rating, count_no
from t1
where rank_of = 1

-- 3. List all movies released in a specific year (e.g., 2020)

select *
from netflix

select title
from netflix
where release_year = '2020'

-- 4. Find the top 5 countries with the most content on Netflix

select new_country, count(*) as no_of_movies
from netflix_normalized
group by new_country
order by 2 desc
limit 5



-- 5. Identify the longest movie

SELECT
	TITLE,
	NEW_DURATION
FROM
	(
		SELECT
			SPLIT_PART(DURATION, ' ', 1)::SMALLINT AS NEW_DURATION,
			*
		FROM
			NETFLIX
		WHERE
			TYPE = 'Movie'
			AND DURATION IS NOT NULL
		ORDER BY
			1 DESC
		LIMIT
			1
	) AS SUBQUERRY




-- 6. Find content added in the last 5 years

SELECT
	*
FROM
	NETFLIX
WHERE
	TO_DATE(DATE_ADDED, 'Month dd,yyyy') >= CURRENT_DATE - INTERVAL '5 Years'


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select 
	title
	,*
from netflix
where director ilike '%rajiv chilaka%'


-- 8. List all TV shows with more than 5 seasons

SELECT
	SPLIT_PART(DURATION, ' ', 1)::SMALLINT AS NEW_DURATION,
	*
FROM
	NETFLIX
WHERE
	TYPE = 'TV Show'
ORDER BY
	1 DESC
LIMIT
	5

-- 9. Count the number of content items in each genre

select new_genre,count(*)
from netflix_genre
group by new_genre
order by 2 desc

-- 10.Find each year and the average numbers of content release in India on netflix. 
-- return top 5 year with highest avg content release!
WITH
	T1 AS (
		SELECT
			RELEASE_YEAR::INT,
			COUNT(*),
			ROUND(
				COUNT(*)::NUMERIC / (
					SELECT
						COUNT(*)
					FROM
						NETFLIX
					WHERE
						COUNTRY LIKE '%India%'
				)::NUMERIC * 100,
				2
			) AS AVG_RELEASE
		FROM
			NETFLIX
		WHERE
			COUNTRY LIKE '%India%'
		GROUP BY
			RELEASE_YEAR::INT
	)
SELECT
	*
FROM
	T1
ORDER BY
	3 DESC
LIMIT
	5


-- 11. List all movies that are documentaries

select *
from netflix
where listed_in ilike '%docu%' and type = 'Movie'

-- 12. Find all content without a director

select *
from netflix
where director is null

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

select 
	*
from netflix
join netflix_casts
on netflix.show_id = netflix_casts.show_id
where netflix_casts.new_casts = 'Salman Khan' and release_year::numeric >= extract(year from current_date) - 10

SELECT * FROM netflix
WHERE 
	casts LIKE '%Salman Khan%'
	AND 
	release_year::numeric > EXTRACT(YEAR FROM CURRENT_DATE) - 10


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT
	NETFLIX_CASTS.NEW_CASTS,
	COUNT(8)
FROM
	NETFLIX
	JOIN NETFLIX_COUNTRY ON NETFLIX.SHOW_ID = NETFLIX_COUNTRY.SHOW_ID
	JOIN NETFLIX_CASTS ON NETFLIX.SHOW_ID = NETFLIX_CASTS.SHOW_ID
WHERE
	NETFLIX_COUNTRY.NEW_COUNTRY = 'India'
	AND NETFLIX.TYPE = 'Movie'
GROUP BY
	NETFLIX_CASTS.NEW_CASTS
ORDER BY
	2 DESC LIMIT
	10
-- 15.
-- Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

SELECT
	CASE
		WHEN DESCRIPTION ilike '%kill%'
		OR DESCRIPTION ilike '%violence%' THEN 'bad'
		ELSE 'good'
	END AS CATEGORY,
	count(8)
FROM
	NETFLIX
group by CATEGORY
