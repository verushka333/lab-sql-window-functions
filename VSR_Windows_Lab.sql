## Challenge 1
## This challenge consists of three exercises that will test your ability to use the SQL RANK() function. 
## You will use it to rank films by their length, their length within the rating category, and by the actor or actress who has acted in the greatest number of films.

## Rank films by their length and create an output table that includes the title, length, and rank columns only. 
## Filter out any rows with null or zero values in the length column.

USE SAKILA;

select
title,
length,
rank() OVER(order by length DESC) as simple_rank
from
	film
WHERE length IS NOT NULL
order by simple_rank ASC;

## Rank films by length within the rating category and create an output table that includes the title, length, rating and rank columns only. Filter out any rows with null or zero values in the length column.
select
title,
length,
rating,
RANK() OVER(PARTITION BY rating ORDER BY length DESC),
rank() OVER(order by rating DESC) as rating_rank
from
	film
WHERE length IS NOT NULL and length <> 0
order by rating_rank ASC;

## Produce a list that shows for each film in the Sakila database, 
## the actor or actress who has acted in the greatest number of films, as well as the total number of films in which they have acted. 
## Hint: Use temporary tables, CTEs, or Views when appropiate to simplify your queries.

CREATE VIEW movies_by_actor AS
(SELECT 
actor.actor_id,first_name,last_name
,COUNT(*) AS number_of_movies
FROM
film_actor
JOIN actor ON film_actor.actor_id = actor.actor_id
GROUP BY actor.actor_id,first_name,last_name),

CREATE VIEW max_movies AS
(SELECT film_actor.film_id,
MAX(number_of_movies) maximum_movies
from film_actor 
JOIN movies_by_actor ON film_actor.actor_id=movies_by_actor.actor_id
GROUP BY film_actor.film_id);

SELECT
title,
concat(first_name, ' ', last_name) as actor_full_name,
number_of_movies
FROM film
JOIN max_movies ON film.film_id= max_movies.film_id
JOIN film_actor ON film.film_id= film_actor.film_id
JOIN movies_by_actor ON film_actor.actor_id=movies_by_actor.actor_id
WHERE maximum_movies=number_of_movies
ORDER BY number_of_movies DESC, title;

## GINA DEGENERERS

## CHALLENGE 2

## This challenge involves analyzing customer activity and retention in the Sakila database to gain insight into business performance. 
## By analyzing customer behavior over time, businesses can identify trends and make data-driven decisions to improve customer retention and increase revenue.
## The goal of this exercise is to perform a comprehensive analysis of customer activity and retention by conducting an analysis on the monthly percentage change in the number of active customers and the number of retained customers. 
## Use the Sakila database and progressively build queries to achieve the desired outcome.

##Step 1. Retrieve the number of monthly active customers, i.e., the number of unique customers who rented a movie in each month.

Create view step1 AS
(select 
month(rental_date) as rental_month,
year(rental_date) rental_year, 
count(distinct customer_id) as number_of_clients
from rental
GROUP BY month(rental_date),
year(rental_date)
ORDER BY month(rental_date), year(rental_date))

##Step 2. Retrieve the number of active users in the previous month.
CREATE VIEW step2 as (SELECT *,
LAG(number_of_clients,1) OVER() previous_month 
FROM step1)

## Step 3. Calculate the percentage change in the number of active customers between the current and previous month.
Create view step3 as 
(select *,  
((number_of_clients/previous_month)*100)-100 as percentage_Change
from step2);

## Step 4. Calculate the number of retained customers every month, i.e., customers who rented movies in the current and previous months.
CREATE VIEW step4 AS
(SELECT 
*,
CASE WHEN number_of_clients >= previous_month 
	THEN previous_month 
    ELSE number_of_clients
    END
FROM 
step3)
SELECT
*
FROM step4 
;

SELECT DISTINCT
month(rental_date) as rental_month,
year(rental_date) rental_year,
customer_id
FROM rental
ORDER BY year(rental_date), month(rental_date)

