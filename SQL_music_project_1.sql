1. Who is the senior most employee based on job title?

Select * from employee
order by levels desc
limit 1
-------------------------------------------------------
2. Which countries have the most Invoices?
select billing_country, count(*) as number_of_invoices from invoice
group by billing_country
order by number_of_invoices desc
limit 3

------------------------------------------------------------------------
3. What are top 3 values of total invoice?

select total from invoice
order by 1 desc 
limit 3


--------------------------------------------------------------------------------------------------
'''4. Which city has the best customers? We would like to throw a promotional Music 
Festival in the city we made the most money. Write a query that returns one city that 
has the highest sum of invoice totals. Return both the city name & sum of all invoice 
totals'''

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

---------------------------------------
'''5. Who is the best customer? The customer who has spent the most money will be 
declared the best customer. Write a query that returns the person who has spent the 
most money'''

select concat(cus.first_name,' ',cus.last_name) as full_name, sum(invo.total) as group_total from customer cus
join invoice invo on 
invo.customer_id = cus.customer_id
group by full_name
order by group_total desc
limit 1

---------------------------------------------------------------------------
'''6. Write query to return the email, first name, last name, & Genre of all Rock Music 
listeners. Return your list ordered alphabetically by email starting with A'''

select  cus.email, cus.first_name, cus.last_name, genre.name
from customer cus join invoice on 
invoice.customer_id = cus.customer_id 
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track .track_id
join genre on track.genre_id =genre.genre_id 
where genre.name like 'Rock'
order by 1
-----------------------------------------------------------------------
'''7.Lets invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands'''

select artist.name, count(artist.name) as Number_of_songs from artist
join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on genre.genre_id = track.genre_id
where genre.name like 'Rock'
Group by artist.name
order by Number_of_songs desc
limit 10
------------------------------------------------------------------------------------------
'''8.Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first'''

select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length from track )
order by milliseconds desc
--------------------------------------------------------------------------------------------------
'''Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent'''

WITH best_selling_artist AS (
SELECT artist.artist_id AS artist_id, artist.name AS artist_name, 
SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM invoice_line
JOIN track ON track.track_id = invoice_line.track_id
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
GROUP BY 1
ORDER BY 3 DESC
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS 
amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;
--------------------------------------------------------------------------------
'''We want to find out the most popular music Genre for each country. We determine the most 
popular genre as the genre with the highest amount of purchases. Write a query that returns each 
country along with the top Genre. For countries where the maximum number of purchases is shared 
return all Genres'''

with cte as (
select genre.name, customer.country,count(invoice_line.quantity) as most_popular_genre,
ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY 
COUNT(invoice_line.quantity) DESC) AS RowNo 
from customer
join invoice on invoice.customer_id =customer.customer_id 
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
join track on track.track_id = invoice_line.track_id
join genre on genre.genre_id = track.genre_id
group by 1,2
order by 2 asc ,3 desc)

select country, name, most_popular_genre from cte 
where rowno <= 1
------------------------------------------------------------------------------------------------
'''Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount'''

with cte as (
select customer.first_name,customer.last_name ,customer.country, sum(invoice.total) as total_spend,
row_number()over(partition by customer.country order by sum(invoice.total) desc ) as rowno
from customer
join invoice on customer.customer_id = invoice.customer_id 
group by 1 ,2,3
order by 3 asc, 4 desc )
select first_name, country, total_spend from cte
where rowno <= 1
------------------------------------------------






