-- Today we continue helping Danny's pizza delivery service, Pizza Runner! Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.
--Danny has lots of questions about his business, this week we'll explore section B. Runner and Customer Experience.

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


-- 1. How many runners signed up for each one week period? (i.e. week starts 2021-01-01)

select
date_trunc('week', registration_date) as week_period,
count(runner_id) as runner_signups
from runners
group by all
order by week_period
;


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pick up the order?

select
avg(zeroifnull(split_part(duration, 'm', 1))) as average_pickup_duration
from runner_orders
where duration != 'null'
;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

select
ro.order_id,
count(co.pizza_id) as num_pizzas,
datediff('minute', co.order_time, ro.pickup_time) as prep_time_min
from runner_orders as ro
join customer_orders as co 
    on co.order_id = ro.order_id
where ro.pickup_time != 'null'
group by all
order by count(co.pizza_id) desc

;

-- 4. What was the average distance travelled for each customer?

select
avg(zeroifnull(split_part(distance, 'k', 1))) as average_distance
from runner_orders
where distance != 'null'
;

-- 5. What was the difference between the longest and shortest delivery times for all orders?

select
max(datediff('minute', co.order_time, ro.pickup_time)) - min(datediff('minute', co.order_time, ro.pickup_time)) difference_between_longest_and_shortest_deliveries
from runner_orders as ro
join customer_orders as co
on co.order_id = ro.order_id
where ro.pickup_time != 'null'
;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- Overall
select
(avg(zeroifnull(split_part(duration, 'm', 1) / zeroifnull(split_part(distance, 'k', 1))))*60) as avg_km_per_hour
from runner_orders
where distance != 'null' and pickup_time != 'null'
;
-- Per Driver
select
runner_id,
(avg(zeroifnull(split_part(duration, 'm', 1) / zeroifnull(split_part(distance, 'k', 1))))*60) as avg_km_per_hour
from runner_orders
where distance != 'null' and pickup_time != 'null'
group by runner_id
;
-- Per Driver per Delivery
select
runner_id,
order_id,
(avg(zeroifnull(split_part(duration, 'm', 1) / zeroifnull(split_part(distance, 'k', 1))))*60) as avg_km_per_hour
from runner_orders
where distance != 'null' and pickup_time != 'null'
group by all
;

-- 7. WHat is the succesful delivery percentage for each runner?

select
runner_id,
concat((avg(case when pickup_time = null or  lower(cancellation) like '%cancel%' then 0 else 100 end)),'%') as percent_successful
from runner_orders
group by all
order by runner_id
;