-- Try the challenge here: https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html

-- Each comment indicates a new step. Each new step will be added on to the previous one.

-- For the transactions file:
-- Filter the transactions to just look at DSB (help)
-- These will be transactions that contain DSB in the Transaction Code field
select *
from pd2023_wk01
where transaction_code like 'DSB%'
;

-- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
select
 transaction_code,
    case
        when online_or_in_person = '1' then 'Online'
        when online_or_in_person = '2' then 'In-Person'
    end as online_or_in_person,
    value,
    customer_code,
    transaction_date
from pd2023_wk01
where transaction_code like 'DSB%'
;

-- Change the date to be the quarter.
select
 transaction_code,
    case
        when online_or_in_person = '1' then 'Online'
        when online_or_in_person = '2' then 'In-Person'
    end as online_or_in_person,
    value,
    customer_code,
    quarter(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as transaction_date
from pd2023_wk01
where transaction_code like 'DSB%'
;

-- Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person)
select
 transaction_code,
    case
        when online_or_in_person = '1' then 'Online'
        when online_or_in_person = '2' then 'In-Person'
    end as online_or_in_person,
    sum(value) as value,
    customer_code,
    quarter(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as quarter
from pd2023_wk01
where transaction_code like 'DSB%'
group by all
;

-- For the targets file:
--      Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
--      Rename the fields
--      Remove the 'Q' from the quarter field and make the data type numeric

select
t.online_or_in_person,
replace(t.quarter, 'Q', '') as quarter,
t.target as value
from pd2023_wk03_targets as t
unpivot(target for quarter in (Q1,Q2,Q3,Q4))
;

-- Join the two datasets together

with x as
(
    select
 transaction_code,
    case
        when online_or_in_person = '1' then 'Online'
        when online_or_in_person = '2' then 'In-Person'
    end as online_or_in_person,
    sum(value) as value,
    customer_code,
    quarter(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as quarter
from pd2023_wk01
where transaction_code like 'DSB%'
group by all
)
select
    x.*,
    t.online_or_in_person,
    replace(t.quarter, 'Q', '')::int as quarter,
    t.target as value
from pd2023_wk03_targets as t
unpivot(target for quarter in (Q1,Q2,Q3,Q4))
    join x
        on x.quarter = replace(t.quarter, 'Q', '')::int
;

-- Remove unnecessary fields and calculate the variance to target for each row.
-- OUTPUT: 
with x as (
    select
    case
        when online_or_in_person = '1' then 'Online'
        when online_or_in_person = '2' then 'In-Person'
    end as online_or_in_person,
    sum(value) as value,
    quarter(to_date(transaction_date, 'DD/MM/YYYY HH24:MI:SS')) as quarter
from pd2023_wk01
where transaction_code like 'DSB%'
group by all
)
select
    t.online_or_in_person,
    replace(t.quarter, 'Q', '')::int as quarter,
    x.value,
    t.target as quarterly_targets,
    x.value - quarterly_targets as variance_to_target
from pd2023_wk03_targets as t
unpivot(target for quarter in (Q1,Q2,Q3,Q4))
    join x on x.online_or_in_person = t.online_or_in_person and x.quarter = replace(t.quarter, 'Q', '')::int
;