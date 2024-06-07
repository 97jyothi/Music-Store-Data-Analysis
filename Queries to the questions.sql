create database music
use music
-- To insert tables click on music database in the schema section of the screen
-- then right click on tables click on table data import wizard and 
-- browse from where you have the csv file and complete the importing procedure


/*who is the senior most employee based on job title*/
select * from employee
order by levels desc
limit 1

/*Which country has the most invoices*/
select count(*) as c, billing_country from invoice
group by billing_country
order by c desc

/*What are top 3 values of total invoices*/
select total from invoice
order by total desc
limit 3

select * from invoice
/*Which city has best customers*/
Select sum(total) as invoice_total,billing_city from invoice
group by billing_city
order by invoice_total desc

/*Who best customer*/
Select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as invoice_total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by invoice_total desc
limit 1

/*Question 6*/
select distinct email, first_name, last_name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
where track_id in(
    select track_id from track
    join genre on track.genre_id=genre.genre_id
    where genre.name like 'Rock'
)
order by email;    


/* Question 7 */
select artist.artist_id, artist.name, count(artist.artist_id) as no_of_songs
from track
join album on album.album_id=track.album_id
join artist on artist.artist_id=album.artist_id
join genre on genre.genre_id=track.genre_id
where genre.name like 'Rock'
group by artist.artist_id
order by no_of_songs desc
limit 10;

/* Question 8*/
select name, milliseconds as song_length from track
where milliseconds > (
      select avg(milliseconds) from track)
order by song_length desc; 

/* Question 9 */
-- Find how much amount spent by each customer on artists? write query to return customer name, artist name and money spent
-- We'll use CTE Common table expressions because multiples tables are involved

-- group by 1 means artist_id and order by 3 means total_sales
with best_selling_artist as (
     select artist.artist_id, artist.name as artist_name, 
     sum(invoice_line.unit_price*invoice_line.quantity) as total_sales
     from invoice_line
     join track on track.track_id=invoice_line.track_id
     join album on album.album_id=track.album_id
     join artist on artist.artist_id=album.artist_id
     group by 1
     order by 3 desc
)
select c.customer_id, c.first_name, c.last_name, bsa.artist_name,
sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id= i.customer_id
join invoice_line il on il.invoice_id=i.invoice_id
join track t on t.track_id=il.track_id
join album alb on alb.album_id=t.album_id
join best_selling_artist bsa on bsa.artist_id=alb.artist_id
group by 1,2,3,4
order by 5 desc;   
     
     
     
-- Question 10
-- Find the most popular music genre for each country.
-- We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top genre.
-- For countries where the maximum number of purchases is shared return all genre     

with popular_genre as (
     select count(invoice_line.quantity) as purchases, customer.country, genre.name, genre.genre_id,
     row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as RowNo
     from invoice_line
     join invoice on invoice.invoice_id=invoice_line.invoice_id
     join customer on customer.customer_id=invoice.customer_id
     join track on track.track_id=invoice_line.track_id
     join genre on genre.genre_id=track.genre_id
     group by 2,3,4
     order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <=1   


-- Question 11
-- Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount is shared, provide all customers who spent this amount

With customer_with_country as (
     select customer.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
     row_number() over(partition by billing_country order by sum(total) desc) as RowNo
     from invoice
     join customer on customer.customer_id=invoice.customer_id
     group by 1,2,3,4
     order by 4 asc, 5 desc)
select * from customer_with_country where RowNo <=1