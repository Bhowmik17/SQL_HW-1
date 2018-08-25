-- 1a. Display the first and last names of all actors from the table `actor`.
SELECT first_name, last_name
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT UPPER(CONCAT(first_name, " ", last_name)) as "ACTOR NAME"
from actor; 

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?
SELECT first_name, last_name, actor_id
FROM actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name
FROM actor
where last_name like "%GEN%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
where last_name LIKE "%LI%";

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
-- p: also populates column 'last_update'!
SELECT * FROM country
where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
  
show columns from actor;

ALTER TABLE actor 
ADD description BLOB;

show columns from actor;


-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor drop description;  

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name)
FROM actor
GROUP BY last_name;

-- 4b. ? List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name, COUNT(last_name)
from actor
group by last_name
having 'last_name_frequency' >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
update actor
set first_name = 'HARPO'
where first_name = 'GROUCHO'
and last_name = 'WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
set first_name = 'GROUCHO'
where first_name = 'HARPO'
and last_name = 'WILLIAMS';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
show create table address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
select s.first_name, s.last_name, a.address
from staff s 
join address a
on (s.address_id = a.address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
select s.first_name, s.last_name, SUM(p.amount)
from staff s 
join payment p 
on (p.staff_id = s.staff_id)
where MONTH(p.payment_date) = 08 AND YEAR(p.payment_date) = 2005
group by s.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
select f.title, COUNT(fa.actor_id) AS 'Actors'
from film_actor AS fa
join film AS f
on f.film_id = fa.film_id
group by f.title
order by Actors desc;

-- 6d.? How many copies of the film `Hunchback Impossible` exist in the inventory system?
select COUNT(film_id)
from inventory
where film_id in 
(select film_id
from film
where title = 'Hunchback Impossible'
);

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
select cus.first_name, cus.last_name, SUM(p.amount) 
from customer AS cus 
join payment AS p 
on (cus.customer_id = p.customer_id)
group by cus.customer_id
order by cus.last_name asc;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have 
-- also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
Select title
from film
where title like'K%'
or title like 'Q%'
and language_id In 
(select language_id 
from language
where name = 'English'
);

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
select first_name, last_name
from actor
where actor_id in
(select actor_id 
from film_actor
where film_id = 
(select film_id
from film
where title = 'Alone Trip'
)
);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.
select first_name, last_name, email, country
from customer cus 
join address a
on (cus.address_id = a.address_id)
join city cit
on (a.city_id = cit.city_id)
join country ctr
on (cit.country_id = ctr.country_id)
WHERE ctr.country = 'canada';


-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.** found in 'category' table that category_id for family movie as 8. 

select f.title, description
from film as f
join film_category as fc
on f.film_id = fc.film_id
where category_id = 8;


-- 7e. Display the most frequently rented movies in descending order.

SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
JOIN rental r
ON (i.inventory_id = r.inventory_id)
JOIN film_text f 
ON (i.film_id = f.film_id)
group by r.inventory_id
order by COUNT(r.inventory_id) DESC;




-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT s.store_id, SUM(amount)
FROM store s
JOIN staff st
ON (st.store_id = s.store_id)
JOIN payment p 
ON (p.staff_id = st.staff_id)
GROUP BY st.store_id
ORDER BY SUM(amount);


-- 7g. Write a query to display for each store its store ID, city, and country.

select s.store_id, city, country
from store AS s
join customer AS cus
on (s.store_id = cus.store_id)
join staff As st
on (s.store_id = st.store_id)
join address AS a
on (cus.address_id = a.address_id)
join city AS ci
on (a.city_id = ci.city_id)
join country co
on (ci.country_id = co.country_id); 


-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the  
-- following tables: category, film_category, inventory, payment, and rental.)


SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY Genre ORDER BY Gross  LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS
SELECT c.name AS 'Genre', SUM(p.amount) AS 'Gross' 
FROM category c
JOIN film_category fc 
ON (c.category_id=fc.category_id)
JOIN inventory i 
ON (fc.film_id=i.film_id)
JOIN rental r 
ON (i.inventory_id=r.inventory_id)
JOIN payment p 
ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;


-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;


-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
-- DROP VIEW top_five_genres;

DROP VIEW top_five_genres;



-- 


