select * from customer limit 20;

--compare contribution of revenue by male and female customers
select gender, sum(purchase_amount) as revenue from customer
group by gender;

--which customers used discount but still spent more than avg purchase amount
select customer_id, purchase_amount
from customer
where discount_applied = 'Yes' and 
purchase_amount >= (select AVG(purchase_amount) from customer);

--which are top5 products with highest avg review rating
select item_purchased, ROUND(AVG(review_rating::numeric),2)
as "Average_product_rating"
from customer
group by item_purchased
order by avg(review_rating) desc limit 5;

--compare avg purchase amounts b/w standard & express shipping
select shipping_type,
round(avg(purchase_amount),2) from customer 
where shipping_type in ('Express', 'Standard')
group by shipping_type;

--do subscribed customers spent more?compare avg spend & total revenue b/w subs & non subs
select subscription_status,
count(customer_id) as total_customers,
round(avg(purchase_amount),2) as avg_spend,
round(sum(purchase_amount)) as total_revenue
from customer
group by subscription_status order by total_revenue, avg_spend desc;

--which 5 prods have highest % of purchases with discounts applied
select item_purchased,
ROUND(100 * sum(case when discount_applied='Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc limit 5;


--segment customers into new, returning, loyal based on their total 
-- num of previous purchases and show count of each segment
with customer_type as (
select customer_id, previous_purchases,
case
	when previous_purchases= 1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
from customer
)
select customer_segment, count(*) as "Number of customers" from customer_type
group by customer_segment;

--what are top 3 purchased products within each category
with item_counts as(
select category, item_purchased,
count(customer_id) as total_orders,
row_number() over (partition by category order by count(customer_id) desc) as item_rank
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders from item_counts where item_rank<=3;

--are customers who are repeat buyers (more than 5 prev purchases) also likely to subscribe?
select subscription_status, count(customer_id) as repeat_buyers
from customer
where previous_purchases>5
group by subscription_status;

--what is revenue contribution of each age group?
select age_group, sum(purchase_amount) as revenue 
from customer
group by age_group order by revenue desc;