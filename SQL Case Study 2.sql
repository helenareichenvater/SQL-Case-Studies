-- Following on from last week's SQL Case Study 1: Danny's Diner, today Danny decided to Uberize pizza delivery and launched a new business, Pizza Runner! Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house).
--      Danny has lots of questions about his business, this week we'll explore section A. Pizza Metrics.


-- Grabbing tables
select *
from customer_orders
;
select *
from pizza_names
;
select *
from pizza_recipes
;
select *
from pizza_toppings
;
select *
from runners
;
select *
from runner_orders
;


-- 1. How many pizzas were ordered?
select
count(pizza_id)
from customer_orders
;

-- 2. How many unique customer orders were made?
select
count(distinct order_id)
from customer_orders
;


-- 3. How many successful orders were delivered by each runner?
select
runner_id,
count(order_id)
from runner_orders
where lower(cancellation) not like '%cancel%' or cancellation is null
group by all
;

-- 4. How many of each type of pizza was delivered?
select
pn.pizza_name,
count(co.pizza_id) as number_of_pizzas
from runner_orders as ro
    join customer_orders as co on co.order_id = ro.order_id
        join pizza_names as pn on pn.pizza_id = co.pizza_id
where lower(cancellation) not like '%cancel%' or cancellation is null
group by all
;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select
co.customer_id,
pn.pizza_name,
count(co.pizza_id) as number_of_pizzas
from runner_orders as ro
    join customer_orders as co on co.order_id = ro.order_id
        join pizza_names as pn on pn.pizza_id = co.pizza_id
where lower(cancellation) not like '%cancel%' or cancellation is null
group by all
order by customer_id
;

-- 6. What was the maximum number of pizzas delivered in a single order?

with pizzacount as (
select
co.order_id,
count(co.pizza_id) as number_of_pizzas
from customer_orders as co
    join runner_orders as ro on ro.order_id = co.order_id
where lower(cancellation) not like '%cancel%' or cancellation is null
group by co.order_id
)
select
order_id,
number_of_pizzas
from pizzacount
where number_of_pizzas = (select max(number_of_pizzas) from pizzacount)
;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes? 
with changesmade as
(select
customer_id,
order_id,
pizza_id,
coalesce(array_size(split(nullif(nullif(co.exclusions, ''), 'null'), ',')), 0)
        + coalesce(array_size(split(nullif(nullif(co.extras, ''), 'null'), ',')), 0) as num_changes
from customer_orders as co
    )
select
cm.customer_id,
sum(case when cm.num_changes = 0 then 0 else 1 end) as pizzas_with_changes,
sum(case when cm.num_changes = 0 then 1 else 0 end) as pizzas_with_no_changes
from changesmade as cm
        join pizza_names as pn on pn.pizza_id = cm.pizza_id
        join runner_orders as ro on ro.order_id = cm.order_id
where lower(cancellation) not like '%cancel%' or cancellation is null
group by cm.customer_id
order by cm.customer_id
;

-- 8. How many pizzas were delivered that have both exclusions and extras?

select
count(pizza_id) as changes
from customer_orders as co
    join runner_orders as ro on ro.order_id = co.order_id
where (exclusions is not null
and exclusions != 'null'
and length(exclusions) > 0)
and (extras is not null
and extras != 'null')
and length(extras) > 0
and ((cancellation) not like '%ancel%' or (cancellation) is null)
;

-- 9. What was the total volume of pizzas ordered for each hour of the day?

select
date_part('hour', order_time) as hour,
count(co.pizza_id) as number_of_pizzas
from customer_orders as co
group by date_part('hour', order_time)
order by hour
;

-- 10. What was the volume of orders for each day or the week?

select
dayname(order_time) as day,
count(co.pizza_id) as number_of_pizzas
from customer_orders as co
group by dayname(order_time)
order by day
;