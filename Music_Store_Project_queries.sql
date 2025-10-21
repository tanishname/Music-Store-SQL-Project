-- QUESTION SET 1 (EASY)

--Q1: Who is the senior most employee based on job title?

select first_name, last_name, levels from employee
ORDER BY levels DESC
LIMIT 1

--Q2 : Which countries have the most invoices?

SELECT billing_country AS b, COUNT(*) FROM invoice
group by b
order by b DESC
LIMIT 1

--Q3 : What are the top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

--Q4 : Which city has the best customers? 
--We would like to throw a promotional musio festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. 
--Return both the city name and sum of all invoice totals

SELECT SUM(total) AS total, billing_city FROM invoice 
GROUP BY billing_city
ORDER BY total DESC
LIMIT 1

--Q5 : Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT c.customer_id, first_name, last_name, SUM(total) AS total_money_spent FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_money_spent DESC
LIMIT 1


-- QUESTION SET 2 (MODERATE)

--Q1 : Write query to return the email, first name, last name and genre of all rock music listners. Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT 
c.first_name,
c.last_name,
c.email,
g.name FROM customer c

JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id

WHERE g.name = 'Rock'
ORDER BY c.email

--Q2: Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name and total track count of the top 10 rock bands.

SELECT a.artist_id, a.name, g.name, COUNT(g.name) AS total FROM artist a

JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
JOIN genre g ON t.genre_id = g.genre_id
WHERE g.name = 'Rock'
GROUP BY a.artist_id, g.name
ORDER BY total DESC
LIMIT 10

--Q3 Return all the track names that have a song length longer than the average song length. Return the name and milliseconds for each track.
-- Order by the song length with the longest songs first.

SELECT name, milliseconds FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC


-- QUESTION SET 3 (ADVANCE)

/*Q1 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name
and total spent.*/

with best_Selling as (select a.artist_id, a.name, sum(il.unit_price * il.quantity) as total_sales from customer as c
JOIN invoice as i ON c.customer_id = i.customer_id
JOIN invoice_line as il ON i.invoice_id = il.invoice_id
JOIN track as t ON il.track_id = t.track_id
JOIN album as al ON t.album_id = al.album_id
JOIN artist as a ON al.artist_id = a.artist_id
group by 1
order by 3 desc
limit 1)

select c.customer_id, c.first_name, c.last_name, bs.name,
sum(il.unit_price * il.quantity) as amount_spent
from customer as c
JOIN invoice as i ON c.customer_id = i.customer_id
JOIN invoice_line as il ON i.invoice_id = il.invoice_id
JOIN track as t ON il.track_id = t.track_id
JOIN album as al ON t.album_id = al.album_id
JOIN best_selling as bs ON al.artist_id = bs.artist_id
group by 1,2,3,4
order by 5 desc;


/*Q2 We want to find out the most popular music genre for each country.
We determine the most popular genre as the genre with the highest amount of purchases.
Write a query that returns each country along with the top genre.
For countries where the maximum number of purchases is shared return all genres. */

with cte as (select i.billing_country, g.name, count(il.quantity) as total_orders from invoice as i
join invoice_line as il ON i.invoice_id= il.invoice_id
JOIN track as t ON il.track_id = t.track_id 
JOIN genre as g ON t.genre_id = g.genre_id
group by 1,2
order by 3 desc),

cte2 as(select billing_country, name, row_number() over(partition by billing_country order by total_orders desc),total_orders from cte
group by 1,2, total_orders)

select * from cte2
where row_number = 1


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

with cte as (select i.billing_country, c.customer_id, sum(il.unit_price * il.quantity) as spent from customer as c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
group by 1,2)

, cte2 as(select *, rank() over(partition by billing_country order by spent desc) as rnk from cte)

select * from cte2
where rnk = 1

















