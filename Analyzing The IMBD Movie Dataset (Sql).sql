use imdb;

select * from director_mapping;
select * from genre;
select * from movie;
select * from ratings;
select * from names;
select * from role_mapping;

-- Query 1: Count the total number of records in each table
select 'director_mapping' as table_name, count(*) as Number_of_records from director_mapping
union
select 'genre', count(*) from genre
union
select 'movie', count(*) from movie
union
select 'names', count(*) from names
union
select 'ratings', count(*) from ratings
union
select 'role_mapping', count(*) from role_mapping;

-- Query 2: Identify columns in the movie table with null values
  
select column_name
from information_schema.columns
where table_name = 'Movie'
and is_nullable = 'YES';

-- Query 3: Total number of movies released each year and Movie release count month-wise each year
select year as release_year, count(*) as total_movies from movie
group by year
order by release_year;

select year as release_year, extract(month from date_published) as month, count(*) as total_movies 
from movie 
group by year, extract(month from date_published)
order by release_year, month;

-- Query 4: Count of movies produced in USA or India in 2019

select year as release_year, country, count(*) as no_of_movies 
from movie 
where year = 2019 and country in ('usa', 'india') 
group by year, country;

-- Query 5: List unique genres and count how many movies belong to each genre


select distinct genre from genre;

select g.genre, count(m.id) as total_movies 
from genre g
join movie m on g.movie_id = m.id
group by g.genre
order by count(m.id) desc;

-- Query 6: Which genre has the highest total number of movies produced?

select g.genre, count(m.id) as total_movies 
from genre g
join movie m on g.movie_id = m.id
group by g.genre
order by total_movies desc 
limit 1;

-- Query 7: Calculate the average movie duration for each genre

select g.genre, avg(m.duration) as average_duration 
from genre g
join movie m on g.movie_id = m.id
group by g.genre;

-- Query 8: Identify actors/actresses who have appeared in more than three movies with an average rating below 5

select n.name, count(r.movie_id) as movie_count 
from names n
join role_mapping rm on n.id = rm.name_id
join ratings r on rm.movie_id = r.movie_id
where r.avg_rating < 5 and rm.category in ('actor', 'actress')
group by n.name
having count(r.movie_id) > 3;

-- Query 9: Find min and max values for each column in the ratings table

select min(avg_rating) as min_avg_rating, max(avg_rating) as max_avg_rating from ratings;

select min(median_rating) as min_median_rating, max(median_rating) as max_median_rating from ratings; 

select min(total_votes) as min_total_votes, max(total_votes) as max_total_votes from ratings;


-- Query 10: Top 10 movies based on average rating

select m.title, r.avg_rating 
from movie m
join ratings r on m.id = r.movie_id
order by r.avg_rating desc
limit 10;

-- Query 11: Summarize ratings table by grouping movies based on their median ratings

select median_rating, count(*) as total_movies 
from ratings 
group by median_rating 
order by median_rating desc;

-- Query 12: How many movies, released in March 2017 in the USA with more than 1,000 votes?

select count(*) 
from movie m
join ratings r on m.id = r.movie_id
join genre g on m.id = g.movie_id
where extract(month from m.date_published) = 3
and extract(year from m.date_published) = 2017
and m.country = 'usa'
and r.total_votes > 1000;

-- Query 13: Find movies from each genre that begin with the word "The " and have an average rating greater than 8

select g.genre, m.title, rt.avg_rating 
from movie m
join ratings rt on m.id = rt.movie_id
join genre g on m.id = g.movie_id
where m.title like 'The%' and rt.avg_rating > 8;

-- Query 14: Movies released between April 1, 2018, and April 1, 2019, with a median rating of 8

select count(*) as released_movies
from movie m
join ratings rt on m.id = rt.movie_id
where m.date_published between '2018-04-01' and '2019-04-01'
and rt.median_rating = 8;

-- Query 17: Top 2 actors whose movies have a median rating of 8 or higher

select n.name, count(m.id) as movie_count 
from names n
join role_mapping r on n.id = r.name_id
join movie m on r.movie_id = m.id
join ratings rt on m.id = rt.movie_id
where rt.median_rating >= 8
group by n.name
order by movie_count desc
limit 2;

-- Query 18: Top 3 production companies based on total votes their movies received

select m.production_company, sum(r.total_votes) as total_votes 
from movie m
join ratings r on m.id = r.movie_id
group by m.production_company
order by total_votes desc 
limit 3;

-- Query 19: Count how many directors have worked on more than 3 movies

select count(movie_id) as movie_count,count(distinct name_id) as number_of_directors
from director_mapping
group by name_id
having count(movie_id) > 3;

-- Query 20: Calculate average height of actors and actresses separately

select 
case 
when category = 'actor' then 'actor'
when category = 'actress' then 'actress'
end as role,
avg(n.height) as average_height
from names n
join role_mapping r on n.id = r.name_id
where r.category in ('actor', 'actress')
group by role;

select avg(n.height) as avg_actor_height
from names n
join role_mapping rm on n.id = rm.name_id
where rm.category = 'actor';

select avg(n.height) as avg_actress_height
from names n
join role_mapping rm on n.id = rm.name_id
where rm.category = 'actress';

-- Query 21: List the 10 oldest movies in the dataset with title, country, and director

select m.title, m.country, n.name as director
from movie m
join director_mapping dm on m.id = dm.movie_id
join names n on dm.name_id = n.id
order by m.date_published
limit 10;

-- Query 22: List the top 5 movies with the highest total votes along with their genres

select m.title, sum(r.total_votes) as total_votes, g.genre 
from movie m
join ratings r on m.id = r.movie_id
join genre g on m.id = g.movie_id
group by m.title, g.genre
order by total_votes desc 
limit 5;

-- Query 23: Identify the movie with the longest duration along with its genre and production company

select m.title, m.duration, g.genre, m.production_company
from movie m
join genre g on m.id = g.movie_id
order by m.duration desc 
limit 1;

-- Query 24: Total number of votes for each movie released in 2018

select m.title, sum(r.total_votes) as total_votes 
from movie m
join ratings r on m.id = r.movie_id
where extract(year from m.date_published) = 2018
group by m.title;

-- Query 25: Most common language in which movies were produced

select languages, count(*) as movie_count 
from movie 
group by languages 
order by movie_count desc 
limit 1;


/*23. Identify the movie with the longest duration, along with its genre and production company. */

SELECT m.title, m.duration, g.genre, m.production_company
FROM movie m
JOIN genre g ON m.id = g.movie_id
ORDER BY m.duration DESC
LIMIT 1;


/*24. Determine the total number of votes for each movie released in 2018. */

SELECT m.title, SUM(r.total_votes) AS total_votes
FROM movie m
JOIN ratings r ON m.id = r.movie_id
WHERE EXTRACT(YEAR FROM m.date_published) = 2018
GROUP BY m.title;


-- Query 15: Do German movies receive more votes on average than Italian movies?
select country, avg(r.total_votes) as avgvotes
from movie m
join ratings r on m.id = r.movie_id
where country in ('Germany', 'Italy')
group by country;
-- Query 16: Identify the columns in the names table that contain null values
select column_name
from information_schema.columns
where table_name = 'names'
and is_nullable = 'YES';

select count(*) 
from movie m
join ratings r on m.id = r.movie_id
join genre g on m.id = g.movie_id
where extract(month from m.date_published) = 3
and extract(year from m.date_published) = 2017
and m.country = 'usa'
and r.total_votes > 1000
and g.genre = 'Drama';
