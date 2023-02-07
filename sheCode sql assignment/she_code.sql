create table if not exists baskets_products (	
	id serial primary key,
	basket_id integer,
	product_id numeric,
	constraint fk_basket_id
	FOREIGN KEY(basket_id)
	references basket(basket_id),
	constraint fk_product_id
	FOREIGN KEY(product_id)
	references product(product_id)
);

select *
from baskets_products;


select *
from basketsdata;


--How many users are in the database?
select count(user_id)
from basketsdata;

-- Number of users: 25240

--How many baskets are in the database?
select count(basket_id)
from basketsdata;
--Number of baskets: 25240

--What is the percentage of baskets that were abandoned?

select 
(sum(abandoned_int) * 100) / count(abandoned_int)
from (select case when abandoned = 'true' then 1
else 0 end as abandoned_int
from basket
) sub;


-- Percentage is 19%

--What is the percentage of baskets sold with discounts?
select (sum(discount) * 100) / count(discount)
from basketsdata;

-- Percentage of discount 6.2%

--What are the discounts?

select distinct(discount)
from basketsid;

--How many baskets are in each discount group?

select count(basket_id), discount
from basketsdata
group by 2;

-- discount of 0 = 17718
-- discount of 0.1 = 2529
-- discount of 0.15 = 2520
-- discount of 0.5 = 1280
-- discount of 0.25 = 1193


select *
from products;


---updated the products table 
-- noticed i didn't specify the primary key
ALTER TABLE productS ADD primary key(product_id);

--The highest revenue was recorded on which day of the week?
select date_part('dow',event_time) day_of_week, max(p.price) highest_revenue
from product p
join baskets_products 
on p.product_id = baskets_products.product_id
join basket b
on b.basket_id = baskets_products.basket_id
group by 1
order by 2 desc;

-- Day of the week that returns the highest revenue is Saturday

-- The highest revenue was recorded on which day?
select date_trunc('day',event_time) day_of_week, max(p.price) highest_revenue
from product p
join baskets_products 
on p.product_id = baskets_products.product_id
join basket b
on b.basket_id = baskets_products.basket_id
group by 1
order by 2 desc;
-- 14th of December 2019 has the highest revenue recorded


--Top 10 most profitable products and their brands
select p.brand, sum(p.price) 
from product p
group by 1
order by 2 desc
LIMIT 10;


--Top 5 most profitable brands
select p.brand, sum(p.price) 
from product p
group by 1
order by 2 desc
LIMIT 5;

--Return the top 10 most profitable customers 
--and how many times they have ordered from the store

select b.user_id, count(b.basket_id)
from basket b
group by 1
order by 2 desc
limit 10;

--Return the total number of orders, total number of items purchased,
--total revenue and total profit at the end of the period

--total number of orders
select count(abandoned)
from basket;

--total number of items of purchased
select count(abandoned)
from basket
where abandoned = 'false'
-- Number of items purchased: 20207

--total revenue
select sum(p.price)
from product p;
-- 102616.82


--total profit 
select sum(p.price) - sum(p.cost)
from product p;
-- 25842.20

--Are there any users that abandoned all their orders? 
--How many are they?

with a1 AS 
(WITH augusta AS 
(with 
	base AS (
	SELECT 
		user_id,
		abandoned,
		CASE
			WHEN abandoned = 'True' THEN 1
			ELSE 0
		END AS newcol
	FROM 
		basket
	ORDER BY 1		
	)
SELECT 
	base.*,
	ROW_NUMBER() OVER (PARTITION BY user_id) AS row_
FROM 
	base
	)
SELECT 
	augusta.user_id,
	COUNT(augusta.user_id) AS count_,
	SUM(augusta.newcol) AS sum_
FROM augusta
GROUP BY augusta.user_id
HAVING COUNT(augusta.user_id) = SUM(augusta.newcol)) 
SELECT COUNT(user_id) from a1
	;
	
-- 4155
	

