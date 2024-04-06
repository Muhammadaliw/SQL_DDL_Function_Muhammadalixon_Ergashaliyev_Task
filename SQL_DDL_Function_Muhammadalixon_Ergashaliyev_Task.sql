/*
Create a view called "sales_revenue_by_category_qtr" that shows the film category and total sales revenue for the current quarter. 
The view should only display categories with at least one sale in the current quarter. The current quarter should be determined dynamically.
*/

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT
    category.name AS category,
    SUM(payment.amount) AS total_sales_revenue
FROM
    payment
JOIN
    rental ON payment.rental_id = rental.rental_id
JOIN
    inventory ON rental.inventory_id = inventory.inventory_id
JOIN
    film ON inventory.film_id = film.film_id
JOIN
    film_category ON film.film_id = film_category.film_id
JOIN
    category ON film_category.category_id = category.category_id
WHERE
    EXTRACT(QUARTER FROM payment.payment_date) = EXTRACT(QUARTER FROM now())
GROUP BY
    category.name;


/*
Create a query language function called "get_sales_revenue_by_category_qtr" 
that accepts one parameter representing the current quarter and returns the same result as the "sales_revenue_by_category_qtr" view.
*/

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr(curr_quarter INT default 0)
RETURNS TABLE (category TEXT, total_sales_revenue NUMERIC(10, 2))
LANGUAGE sql
AS
$$
    SELECT
        category.name AS category,
        SUM(payment.amount) AS total_sales_revenue
    FROM
        payment
    JOIN
        rental ON payment.rental_id = rental.rental_id
    JOIN
        inventory ON rental.inventory_id = inventory.inventory_id
    JOIN
        film ON inventory.film_id = film.film_id
    JOIN
        film_category ON film.film_id = film_category.film_id
    JOIN
        category ON film_category.category_id = category.category_id
    WHERE
        EXTRACT(QUARTER FROM payment.payment_date) = curr_quarter
    GROUP BY
        category.name;
$$;

/*
Create a procedure language function called "new_movie" that takes a movie title as a parameter and inserts a new movie with the given title in the film table.
The function should generate a new unique film ID, set the rental rate to 4.99, 
the rental duration to three days, the replacement cost to 19.99, the release year to the current year, and "language" as Klingon. 
The function should also verify that the language exists in the "language" table. Then, ensure that no such function has been created before; if so, replace it.
*/

CREATE OR REPLACE PROCEDURE new_movie(IN movie_title VARCHAR(255))
LANGUAGE plpgsql
AS
$$
DECLARE
    new_film_id INT;
BEGIN
    -- Ensure the existence of the Klingon language
    PERFORM language_id FROM language WHERE name = 'Klingon';
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Language not found: Klingon';
    END IF;

    -- Get the new film ID
    SELECT COALESCE(MAX(film_id), 0) + 1 INTO new_film_id FROM film;

    -- Insert the new movie
    INSERT INTO film (film_id, title, rental_rate, rental_duration, replacement_cost, release_year, language_id)
    VALUES (new_film_id, movie_title, 4.99, 3, 19.99, EXTRACT(YEAR FROM CURRENT_DATE), (SELECT language_id FROM language WHERE name = 'Klingon'));
END;
$$;
