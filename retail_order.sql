create table orders_df (
	order_id int primary key,
	order_date date,
	ship_mode varchar(20),
	segment varchar(20),
	country varchar(20),
	city varchar(20),
    state varchar(20) ,
	postal_code varchar(20),
	region varchar(20) ,
	category varchar(20) ,
	sub_category varchar(20),
    product_id varchar(20),
	quantity int,
	discount decimal(7,2), 
	sold_price decimal(7,2) ,
	profit decimal(7,2)
);
select * from orders_df


-- find the top 10 highest revenue generation product
			-- for each product what is the total sale
select  product_id, sum(sold_price) as revenue
from orders_df
group by product_id
order by  revenue desc
limit 10

-- find the top 5 highest selling product in each region 
select distinct region from orders_df

select region, product_id, sum(sold_price) as revenue
from orders_df
group by region, product_id
order by region, revenue


-- now genetaret a rank
with cte as (
	select region, product_id, sum(sold_price) as revenue
	from orders_df
	group by region, product_id	
)
select *
	, row_number() over (partition by region order by revenue desc) as rn    
	from cte


-- now get the top 5 ranking for each region

with cte as (
	select region, product_id, sum(sold_price) as revenue
	from orders_df
	group by region, product_id	
)
select * from(

	select *
	,row_number() over (partition by region order by revenue desc) as rn    
	from cte) as A
where rn <=5;


-- 3 find month over month growth **comparision** for 2022 and 2023 slaes 
------- eg: jan 2022 vs jan 2023

select  distinct extract (year from order_date) as years
 from orders_df

-- now compare
-- what is the sales in 22 and 23
select  distinct extract (year from order_date) as years, 
		extract (month from order_date) as months,
		sum (sold_price) as sales

from  orders_df
group by distinct extract (year from order_date),
		extract (month from order_date)
order by  extract (year from order_date),
		extract (month from order_date)


-- now put month vise in separate col
-- with cte as (select  distinct extract (year from order_date) as years, 
-- 		extract (month from order_date) as months,
-- 		sum (sold_price) as sales

-- from  orders_df
-- group by distinct extract (year from order_date),
-- 		extract (month from order_date)
-- order by  extract (year from order_date),
-- 		extract (month from order_date)
-- 	)
-- select months 
-- 	, case when years = 2022 then sales else 0 end
-- 	, case when years = 2023 then sales else 0 end
-- from cte
-- group by months



with cte as (

	select distinct extract(year from order_date) as order_year,
					extract (month from order_date) as order_month,
					sum(sold_price) as sales
	from orders_df
	group by order_year,
			 order_month
	order by order_year,
			 order_month
	
)
select order_month,
	sum(
	case 
		when order_year = 2022 then sales
		else 0
		end 
	) as "sales_2022",
	sum
	(case
	when order_year = 2023 then sales 
	else
	0
	end  ) as "sales_2023"
	
from cte 	
group by order_month
order by order_month



-- 4 for each category how much is the sales month wise
with cte as(select category, extract (month from order_date) as order_month, sum(sold_price) as sale
from orders_df
group by category, order_month)
	select  category, order_month, sale
, row_number() over (partition by category order by order_month) as rn
from cte
group by category, order_month, sale


	
-- 5 for each category which month had highest sales 
select category, to_char(order_date, 'yyyy/mm') as order_year_month, sum(sold_price) as sales
	from orders_df
	group by category, to_char(order_date, 'yyyy/mm')
	order by category, to_char(order_date, 'yyyy/mm')

-- now which month saw the highest sales
--- convert it to cte

with cte as(
	select category, to_char(order_date, 'yyyy/mm') as order_year_month, sum(sold_price) as sales
	from orders_df
	group by category, to_char(order_date, 'yyyy/mm')
	order by category, to_char(order_date, 'yyyy/mm')
)
	select * from(select *, 
	row_number() over (partition by category order by sales desc) as rn
from cte) a
where rn = 1



---- 6 whcih sub_category had highest growth by profit in 2023 campared to 2022
with cte as (
	select sub_category, extract(year from order_date) as order_year,
			sum(sold_price) as sales
	from orders_df
	group by sub_category, order_year
	order by sub_category, order_year
	
)
,cte2 as (
	select sub_category,

	sum(
	case
	when order_year = 2022 then sales
	else 0
	end
	) as "sales_2022",
	sum(
	case
	when order_year = 2023 then sales
	else 0
	end
	) as "sales_2023"

from cte
group by sub_category
)
select *,
	(sales_2023-sales_2022)*100/sales_2022 as grwoth -- profit 
	from cte2
order by grwoth  desc
limit 1

select * from orders_df