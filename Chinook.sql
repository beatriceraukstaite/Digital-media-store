/*Chinook practice*/
select * from album;
select * from artist;
select * from customer;
select * from employee;
select * from genre;
select * from invoice;
select * from invoice_line;
select * from media_type;
select * from playlist;
select * from playlist_track;
select * from track;

/*distribution of customers by country*/
select country, count(customer_id) as customer_count from customer group by dec country;
select country, count(customer_id) as customer_count from customer group by country order by customer_count desc;
--top 10
select country, count(customer_id) as customer_count from customer group by country order by customer_count desc limit 10;

create table "top10 customer_bycountry" (
Country varchar,
Quantity int);
insert into "top10 customer_bycountry" (Country,Quantity)
select country, count(customer_id)
from customer
group by country;

select * from "top10 customer_bycountry" order by quantity desc;

drop table "top10 customer_bycountry";

/*The country with the largest purchase of iTunes services*/
select * from customer;
select * from invoice;

create table top_countries_bybilling as select 
	a.country,
	sum(total)
from customer as a
inner join invoice as b
on a.customer_id=b.customer_id
group by a.country
order by sum(total)desc;

select * from top_countries_bybilling;
			   
select *, 
rank() over (partition by country order by sum desc) as rank_n
from top_countries_bybilling;

/*Top city for Itunes services*/
create table ranked_cities as select
	a.city,
	a.country,
	sum(total),
	dense_rank() over (partition by a.country order by sum(total) desc) as d_rank
from customer as a
inner join invoice as b
on a.customer_id=b.customer_id
group by a.city, a.country;

create table top3_cities as select * from ranked_cities where d_rank<=3;
select * from top3_cities;

/*The most popular song*/
--in general, by country, by city
select * from track;
select * from invoice_line;

create table top_songs_total as select
	a.name as song_name,
	c.name as genre_name,
	count(invoice_id)
from track as a
left join invoice_line as b
on a.track_id=b.track_id
left join genre as c
on a.genre_id=c.genre_id
group by a.name,c.name
order by count(invoice_id) desc limit 18;

drop table top_songs_total;
select * from top_songs_total;

--by country
select * from invoice_line;
create table top_songs_bycountry as select
	a.track_id,
	a.name,
	c.billing_country,
	count(b.invoice_id),
	dense_rank() over (partition by c.billing_country order by count(b.invoice_id) desc) as d_rank
from track as a
left join invoice_line as b
on a.track_id=b.track_id
left join (select d.invoice_id,d.billing_country,e.track_id from invoice as d right join invoice_line as e on d.invoice_id=e.invoice_id) as c
on a.track_id=c.track_id
group by a.name, c.billing_country, a.track_id
order by count desc;

------------------------
/*Duration of the most popular songs*/
create table pop_songs_duration as select
	a.name as song_name,
	c.name as genre_name,
	a.milliseconds,
	count(invoice_id)
from track as a
left join invoice_line as b
on a.track_id=b.track_id
left join genre as c
on a.genre_id=c.genre_id
group by a.name,c.name,a.milliseconds
order by count(invoice_id) desc limit 256;

select * from pop_songs_duration;
select * from top_songs_total;

select avg(milliseconds)from pop_songs_duration;

--duration of the most popular songs in general
create table pop_total_songs_duration as select 
	a.*,
	b.milliseconds
from top_songs_total as a
left join track as b
on a.song_name=b.name
group by a.song_name,a.genre_name,a.count,b.milliseconds
order by count desc;

select * from pop_total_songs_duration;
select avg(milliseconds) from pop_total_songs_duration;

/*The most popular playlist*/
select * from playlist;
select * from playlist_track;

--in general
create table pop_playlist as select 
	count(a.playlist_id),
	b.name
from playlist_track as a
left join playlist as b
on a.playlist_id=b.playlist_id
group by a.playlist_id,b.name
order by count(a.playlist_id) desc;

select * from pop_playlist;

--by country
select * from top_songs_bycountry;
select * from playlist_track;

create table pop_playlist_bycountry as select
	b.*,
	c.name as playlist_name
from playlist_track as a
right join top_songs_bycountry as b
on a.track_id=b.track_id
right join playlist as c
on a.playlist_id=c.playlist_id
group by b.name, b.billing_country, b.track_id,b.count,b.d_rank, c.name
order by count desc;

select * from pop_playlist_bycountry where pop_playlist_bycountry is not null;

/*The most popular album*/
select * from track;
create table pop_album as select 
	count(a.album_id),
	a.album_id,
	b.name as genre_name,
	c.title as album_name
from track as a
left join genre as b
on a.genre_id=b.genre_id
left join album as c
on a.album_id=c.album_id
group by a.album_id,b.name,c.title
order by count(a.album_id) desc;

select * from pop_album;
--The most popular series
select * from pop_album where genre_name='TV Shows';

/*The most popular artist*/
select * from album;

create table pop_album_and_artist as select 
	b.genre_name,
	b.album_name,
	b.count as album_quantity,
	c.name as artist_name
from album as a
right join pop_album as b
on a.album_id=b.album_id
left join artist as c
on a.artist_id=c.artist_id
group by b.album_id,b.genre_name,b.album_name,b.count,c.name
order by count desc;

select * from pop_album_and_artist;
drop table pop_album_and_artist;

/*The most popular genre*/
select genre_name, count(*) from pop_album_and_artist group by genre_name order by count(*) desc;

