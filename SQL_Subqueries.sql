# In this lab, you will be using the Sakila database of movie rentals.
USE sakila;


# 1. How many copies of the film Hunchback Impossible exist in the inventory system?

SELECT 
    COUNT(inventory_id) AS number_of_copies
FROM
    inventory
WHERE
    film_id = (SELECT 
            film_id
        FROM
            film
        WHERE
            title = 'Hunchback Impossible');


# 2. List all films whose length is longer than the average of all the films.

SELECT 
    title, length
FROM
    film
WHERE
    length > (SELECT 
            AVG(length)
        FROM
            film)
ORDER BY length DESC;


# 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id = (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = "Alone Trip"));


# 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.

SELECT 
    title
FROM
    film
WHERE
    film_id IN (SELECT 
            film_id
        FROM
            film_category
        WHERE
            category_id = (SELECT 
                    category_id
                FROM
                    category
                WHERE
                    name = 'Family'));


# 5. Get name and email from customers from Canada using subqueries. Do the same with joins.

# Using Subqueries
SELECT 
    first_name, last_name, email
FROM
    customer
WHERE
    address_id IN (SELECT 
            address_id
        FROM
            address
        WHERE
            city_id IN (SELECT 
                    city_id
                FROM
                    city
                WHERE
                    country_id IN (SELECT 
                            country_id
                        FROM
                            country
                        WHERE
                            country = "Canada")));


# Using Joins
SELECT 
    first_name, last_name, email, country
FROM
    customer
        JOIN
    address ON customer.address_id = address.address_id
        JOIN
    city ON address.city_id = city.city_id
        JOIN
    country ON city.country_id = country.country_id
WHERE
    country = 'Canada';


# 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.

SELECT 
    actor_id, COUNT(film_id) AS total_films
FROM
    film_actor
GROUP BY actor_id
ORDER BY total_films DESC LIMIT 1;


SELECT title as films_starred
FROM film 
WHERE film_id IN (SELECT film_id 
			FROM film_actor 
			WHERE actor_id = 107);


# 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

SELECT title
FROM film
WHERE film_id IN (SELECT inventory.film_id
                  FROM inventory
                  JOIN rental ON inventory.inventory_id = rental.inventory_id
                  JOIN payment ON rental.rental_id = payment.rental_id
                  WHERE payment.customer_id = (SELECT customer_id FROM payment GROUP BY customer_id ORDER BY SUM(amount) DESC LIMIT 1)
                  );


# 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT 
    customer_id, SUM(amount) AS total_amount_spent
FROM
    payment
GROUP BY customer_id
HAVING SUM(amount) > (SELECT 
        AVG(total_amount_spent)
    FROM
        (SELECT 
            customer_id, SUM(amount) AS total_amount_spent
        FROM
            payment
        GROUP BY customer_id) AS customer_spending);