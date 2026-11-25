

use flipkart_clean;

select * from customers;

-- 1. average age of every state!
select
	state,
    avg(age) as avg_age
from customers
group by state;


select * from customers;

-- 2. calculate the gender wise customers!

select
	gender,
    count(*) as total_customers
from customers
group by gender;

select * from customers;

-- 3. fetch out all the plus members people!

select
	customer_id,
    customer_name, 
    is_plus_member
from customers
where is_plus_member = 1;


-- 4. get the count of plus members people in every gender!

-- where -> is_plus_member
-- group by -> gender

select
		gender,
        count(customer_id) as total_customers
from customers
where is_plus_member = 1
group by gender ;
-- flow of sql executions!

-- from -> where -> group by -> ... -> select groupng, aggr


-- 5. we want to know gender wise, whether the customer is plus or not !
-- so, get their counts in  a structured way!

-- group by -> gender, is_plus_memebre!

select
	gender, is_plus_member,
    count(*) as total_cases
from customers
group by gender, is_plus_member
order by gender, is_plus_member;
-- order by total_cases;

-- 6. from the above result, get all the combinations!
-- where we have total cases above 10000!


select
	gender, is_plus_member,
    count(*) as total_cases
from customers
group by gender, is_plus_member
having total_cases > 10000
order by gender, is_plus_member;

-- where -> mainly use to filter the rows based on the condtions like
-- having -> used to filter the groups!
-- bth can use logical op. (and, or , not), comparison op(>, >=, <, <=, ==, !=)

select * from order_items;

-- 7. find the total items, and the total quantities in every order! (order_items)

-- order_id | total_items | total_qty

select
	order_id,
    count(order_item_id) as total_items,
    sum(quantity) as total_qty
from order_items
group by order_id;

-- 8. find how many orders are delivered in the month of April, 2022!
-- (order_items)

-- (unqiue counts of orders!)

select
	-- count(distinct order_id) as total_order
    *
from order_items
where monthname(delivered_date) = "April" and year(delivered_date) = 2022
and item_status = "Delivered";


select * from order_items;

-- 9. get all the order_items data where the review rating is not present!
-- NULL -> 
-- 0? -> No!
-- Empty ! -? blank -? void!
select
	*
from order_items
where review_rating is NULL;

-- is -> a special operator to handle the null values cases!

select * from products;
-- 10. from the products table, get all the "sunscreen" products!
-- like!

-- string form !
-- is like "sunscreen"
-- "%sunscreen"
-- "%sunscreen%"

select
	*
from products
where product_name like "%sunscreen%";

-- 11. get all the products with the brand name as "Nivea" at the starting only!

select * from products;

select 
	*
from products
where product_name like "%nivea%";


-- 12. get all the products, which have "100 ml" in their products names!

-- 13. get all the unique sellers, who have 521 in ther 3rd place of id's

-- 14. get all the products which has "2u" in their 4th index of product_id!
select
	*
from products
where product_id like "___2U%";



-- 15 get all the products which has "2U" in their 4th index of product id, and "2C" 
-- at end!
select 
	*
from products
where product_id like "___2U%2C";


-- 16. those products which provides the discount of over 20%

select
	*,
	(mrp - selling_price) as discount,
    ( ( mrp - selling_price ) / mrp )
from products
where ( ( mrp - selling_price ) / mrp ) < 0.20;


-- 17. get the average rating of every brand in every category, and also show, the 
-- total number of products there! 

-- category | brand | avg_rating | number_of_products

select * from customers;

-- 18. create a output in a way that shows a grouped result as:
-- tier | gender | is_plus_member | total_customers | average_age
-- of those customers who registered in the 2021 or 2024!




select * from returns;

-- 19. find which issue has made the highest loss from revenue!
select 
	return_reason,
    sum(refund_amount) as revenue_loss
from returns
group by return_reason 
order by revenue_loss desc;

select * from products;

-- 20. accroding to the product rating, add a label to every product in such way:
-- (case when then)
-- 0 <= 1 -> "Poor",
-- <=2 -> "Average",
-- <= 3 -> "Good"
-- <=4 -> "Very Good"
-- <=5 -> "Excellent"

select
	*,
    case 
		when rating > 0 and rating <=1 then "Poor"
        when rating <=2 then "Average"
        when rating <= 3 then "Good"
        when rating <= 4 then "Very Good"
        when rating <= 5 then "Excellent"
        else "Not Valid"
	end as rating_status
from products;


select * from orders;

-- 1. want to know, which all sale events we have!
-- group by, distinct!

-- 2. for every status, how many UPI cases are there!
-- where -> payment mode
-- group by -> order_status

-- 3. whats the original amoutn before discount
-- (total_amt + disc) as amt before disc

select * from order_items;

-- 4. we wnat to know, all the items , when he rating is given but the revie text is missing!
-- where -> 
-- rating is not null and text is null

-- 5. we want to add yhe quarters to ever delivered date!
-- jan - mar = q1
-- apr - june - q2
-- q3
-- q3
-- case  -> 
-- when monthname(deliver_dt)  in ("Jan", Feb, Mar) then "Q1"

select * from returns;

-- 6. get the returns from last quarters, and show theri total revenue loss!
-- view, cte!

-- between month(oct) , 

select * from customers;

-- 7.  i wnat to know all those customers, who are refreed by someone!
select 
	distinct referred_by_customer_id
from customers;


-- query writing!
-- basic queries!
-- *, coln, as, from, where, multiple filtering, like, log, compar, dates, ...
-- group having, order lmit offset!


-- depthful!
-- Joins!
-- Subqueries!
-- window functions!

-- besides, 
-- conceptual thinking, which db to choose, why, dbms concepts!
-- optimizations!
-- Transactions -> SQL -> ACID, Nomralizations!




-- Joins

-- 28. get all customers who made the orders!
select
	count(*)
from customers
join orders
on customers.customer_id = orders.customer_id;

-- inner join -> 
-- it returns the common entries!
-- from above, context, we can say!
-- all the customers, who had made the orders! (not geeting the customers who not made any order!)


-- customer -> c_id -> p.k


-- 29. get all the orders, and their order items!
select
	*
from orders
join order_items
on orders.order_id = order_items.order_id;

-- 30. get the customers, order details, and items data together!
-- get all the customers details, who made the order!
-- (inner join)
-- then from those orders, get their items details as well! like quatities, !
select
	*
from customers 
join orders
on customers.customer_id = orders.customer_id
join order_items 
on orders.order_id = order_items.order_id;

-- denormalization!


select 
	count(*)
from orders
join customers
on customers.customer_id = orders.customer_id;

-- 31.
select
	count(*)
from customers as c
left join orders as o
on c.customer_id = o.customer_id;
-- all those customer who has made the orders!
-- but, also we are gettig those customer who didn't made any order! (exclsuive content of left table)


-- 32. 
-- we wnat the customers who don't makes any orders! (left table exclusive cases!)
select
	c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    o.total_amount,
    o.customer_id,
    o.payment_mode
from customers as c
left join  orders as o
on c.customer_id = o.customer_id
where o.customer_id is null;


-- 33. get the customer names, ids, email and payment mode of those who made some orders, using UPI's.
-- inner join! -> common
-- left join! -> extract
select
	c.customer_name,
    c.customer_id,
    c.email,
    o.payment_mode
from customers as c
join orders as o
on c.customer_id = o.customer_id
where o.payment_mode = "UPI";


-- 34. for those customers, who not made any order, get their email ids!
-- left join! -> common + exlcuive content of left table!
select
	-- count(c.email)
    c.email
from customers as c
left join orders as o
on c.customer_id = o.customer_id
where o.customer_id is null;

-- 35. find the gender wise, total orders, total revenue, and avg discount we gave 
-- from flipkart

-- Genders | total order | total amount | avg discount 

select
	c.gender as Gender,
    count(o.order_id) as total_orders,
    sum(o.total_amount) as revenue,
    round( avg(o.discount_amount), 2)  as avg_discount
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by c.gender;

-- we can calc. the percentage wise, contributin of total orders later!




-- assuming, common entries!

select
	*
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join returns as r
on oi.order_item_id = r.order_item_id;

-- 36. calcuate the city-tier wise total return cases!
select
	tier,
    count(r.return_id) as total_return_cases
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join returns as r
on oi.order_item_id = r.order_item_id
group by tier;

-- for this, col, single time!

-- 38. calc. the total amount of revenue from orders, which belongs to "Himalaya" brand
-- and have items above 4 !

select
	sum( quantity * unit_price) as amt
from order_items as oi
join products as p
on oi.product_id = p.product_id
where brand = "Himalaya" and quantity > 3;

-- cross join!


select * from products;



-- 39. find which product has maximum returns!

select
	p.product_id,
    p.product_name,
    count(r.return_id) as total_returns
   --  max(p.product_name),
--     count(r.return_id)
from products as p
join order_items as oi
on p.product_id = oi.product_id
join returns as r
on oi.order_item_id = r.order_item_id
group by p.product_id
order by total_returns desc;


-- 40. find the top 50 customer details, who made the highest amt of single time 
-- purchase!


-- cross join!
-- number of rows ==  m * n!
-- m -> records in table 1
-- n -> records in table 2
-- redudancy is at peak, too much compelxit and duplicay precent here!
select
	count(*)
from customers as c
cross join orders as o;

-- self join!
-- when we want to merge the table by itself!
select
	*
from customers as c1
join customers as c2
on c1.referred_by_customer_id = c2.customer_id;




select * from customers;

-- find out the customers who are at the 2nd highest age 
-- ranking func,

-- limit, rank!

select * from customers
order by age desc
limit 2;

select 	
	*
from (
select
	*,
    dense_rank() over(order by age desc) as age_rnk
from customers ) as e
where age_rnk = 6;

