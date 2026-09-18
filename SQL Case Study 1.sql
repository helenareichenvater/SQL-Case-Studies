-- Today we'll be visiting Danny's Diner. Danny seriously loves Japanese food so at the beginning of 2021, he decides to embark upon a risky venture and opens up a cute little restaurant that sells his 3 favourite foods: sushi, curry and ramen.
--      Danny’s Diner is in need of your assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business.


-- Viewing OG Tables
select *
from members
;
select *
from menu
;
select *
from sales
;

-- 1. What is the total amount each customer spent at the restaurant?
select
s.customer_id,
sum(m.price) as total_sales
from sales as s
join menu as m on m.product_id = s.product_id
group by s.customer_id
;

-- 2. How many days has each customer visited the restaurant?
select
customer_id,
count(distinct order_date) as days_visited
from sales
group by customer_id
;

-- 3. What was the first item from the menu purchased by each customer?
with fp as (
select
    product_id,
    order_date,
    customer_id,
     row_number() over(partition by customer_id order by order_date asc) as rn
from sales
)
select
    fp.customer_id,
    fp.order_date,
    m.product_name as first_purchase
from fp
    join menu as m on m.product_id=fp.product_id
where rn = 1
;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select
m.product_name,
count(s.order_date) as number_of_purchases
from sales as s
    join menu as m on s.product_id = m.product_id
group by all
order by number_of_purchases desc
limit 1
;

-- 5. Which item was the most popular for each customer?
with fp as (
select
    product_id,
    customer_id,
    count(order_date) as number_of_purchases,
    row_number() over(partition by customer_id order by count(order_date) desc) as rn
from sales
group by all
)
select
    fp.customer_id,
    m.product_name as favorite_purchase,
    fp.number_of_purchases
from fp
    join menu as m on m.product_id = fp.product_id
where fp.rn = 1
;

-- 6. Which item was purchased first by the customer after they became a member?
with fp as (
select
    s.product_id,
    s.order_date,
    s.customer_id,
    m.product_name,
    row_number() over(partition by s.customer_id order by s.order_date asc) as rn
from sales as s
join menu as m on m.product_id=s.product_id
join members as mem on mem.customer_id = s.customer_id
where s.order_date >= join_date
order by s.order_date asc
)
select
    customer_id,
    min(order_date) as order_date,
    product_name as first_purchase
from fp
where rn = 1
group by all
;

-- 7. Which item was purchased just before the customer became a member?
with fp as (
select
    s.product_id,
    s.order_date,
    s.customer_id,
    m.product_name,
    row_number() over(partition by s.customer_id order by s.order_date desc) as rn
from sales as s
join menu as m on m.product_id=s.product_id
join members as mem on mem.customer_id = s.customer_id
where s.order_date < join_date
order by s.order_date asc
)
select
    customer_id,
    min(order_date) as order_date,
    product_name as first_purchase
from fp
where rn = 1
group by all
;

-- 8. What is the total items and amount spent for each member before they became a member?
with fp as (
select
    s.product_id,
    s.order_date,
    s.customer_id,
    m.price,
    m.product_name
from sales as s
join menu as m on m.product_id=s.product_id
join members as mem on mem.customer_id = s.customer_id
where s.order_date < join_date
order by s.order_date asc
)
select
    customer_id,
    count(product_id) as items_purchased,
    sum(price) as amount_spent
from fp
group by all
;

-- 9. If each $1 spend equates to 10 points and sushi has a 2x multiplier - how many points would each customer have?
select
    s.customer_id,
    sum(case when product_name = 'sushi' then price*20 else price*10 end) as points
from sales as s
join menu as m on m.product_id=s.product_id
group by customer_id
;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items not just sushi- how many points do customers A and B have at the end of January?
with pointscalc as(
    select
        s.customer_id,
        s.order_date,
        mem.join_date,
        sum(case when product_name = 'sushi' then price*20 else price*10 end) as normp,
        sum(price*20) as memp,
from sales as s
join menu as m on m.product_id=s.product_id
join members as mem on mem.customer_id = s.customer_id
group by s.customer_id, s.order_date,  mem.join_date
)
select
customer_id,
sum(case when (datediff(day, order_date, join_date)) > 7 then pointscalc.memp else pointscalc.normp end) as points
from pointscalc
group by all
;