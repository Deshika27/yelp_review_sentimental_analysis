-- find no of businesses in each category
with cte as(
select business_id,trim(A.value) as category
from tbl_yelp_businesses
,lateral split_to_table(categories,',') A)
select category, count(*) as no_of_business
from cte
group by 1
order by 2 desc;

-- find top 10 users who have reviewed the most businesses in the "Restaurant" category
select top 10 r.user_id,count(distinct b.business_id) as no_of_reviews 
from tbl_yelp_reviews as r
inner join tbl_yelp_businesses as b on r.business_id = b.business_id
where b.categories ilike '%restaurant%'
group by 1
order by 2 desc

-- find the most popular categories of businesses (based on the number of reviews)
with cte as(
select business_id,trim(A.value) as category
from tbl_yelp_businesses
,lateral split_to_table(categories,',') A)
select category, count(*) as no_of_reviews
from cte
inner join tbl_yelp_reviews as r on r.business_id = cte.business_id
group by 1
order by 2 desc

-- find top 3 most recent reviews for each business
with cte as(
select * 
,row_number() over(partition by business_id order by review_date desc) as rn
from tbl_yelp_reviews)
select * 
from cte
where rn <= 3

-- find the month with the highest reviews
select month(review_date) as month, count(*) as no_of_reviews
from ©
group by 1
order by 2 desc

-- find the percentage of 5-star reviews for each business
select business_id
, count(*) as total_review
, sum(case when review_stars=5 then 1 else 0 end) as five_star_review
, (five_star_review/total_review)*100 as five_star_review_percentage
from tbl_yelp_reviews
group by 1
order by 3 desc

-- find the top 5 most reviewed businesses in each city
with cte as (
select b.city as city
,b.business_id as business_id
,count(*) as no_of_reviews
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b on r.business_id = b.business_id
group by 1,2
)
select *
from cte
qualify row_number() over(partition by city order by no_of_reviews desc) <= 5

-- find the average rating of businesses that have at least 100 reviews
select business_id
,count(*) as no_of_reviews
,avg(review_stars) as avg_rate
from tbl_yelp_reviews 
group by 1
having no_of_reviews >= 100

-- List the top 10 users who have written the most reviews. along with the businesses they reviewed.
select user_id
-- ,array_agg(business_id) AS business_ids
,listagg(business_id, ', ') businesses
,count(*) as no_of_reviews
from tbl_yelp_reviews
group by 1
order by 3 desc
limit 10

-- find top 10 businesses with highest positive sentiment reviews
select business_id
,count(*) as positive_review_count
from tbl_yelp_reviews
where sentiments = 'Positive'
group by 1
order by 2 desc
limit 10