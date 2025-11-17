CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  select * from sales;
  select * from members;
  select * from menu;
  
  
  
  
-- 1. What is the total amount each customer spent at the restaurant?
select customer_id, sum(price) as total_spent
from sales S join menu m 
on S.product_id = m.product_id
group by 1
order by 2 desc;

-- 2. How many days has each customer visited the restaurant?

select customer_id, count(distinct order_date) as no_of_days
from sales
group by 1;


-- 3. What was the first item from the menu purchased by each customer?

with rnk as (select customer_id, product_name, order_date, dense_rank() over (partition by customer_id order by order_date ) as rn
from sales S join menu M
on S.product_id = M.product_id
group by 1,2,3)

select customer_id, product_name
from rnk
where rn = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?


select product_name, count(S.product_id) as sale_count from sales S join menu M 
where S.product_id = M.product_id
group by 1
order by 2 desc
limit 1;

WITH RANKING AS (
SELECT 
          product_name,
          COUNT(sales.PRODUCT_ID) AS TOTAL_COUNT,
          rank() over(order by COUNT(sales.PRODUCT_ID) DESC ) AS RANKS
FROM
          sales JOIN menu
WHERE
	      sales.product_id=menu.product_id
GROUP BY
          product_name
)     
SELECT
       product_name,
       TOTAL_COUNT
FROM
       RANKING
WHERE
       RANKS=1;

select * from sales;
-- 5. Which item was the most popular for each customer?

with rnk as(select customer_id, product_id, count(product_id) as count_of_product, dense_rank() over(partition by customer_id order by count(product_id) desc) as rn
from sales
group by 1, 2)

select customer_id,count_of_product, product_name 
from rnk R join menu M
on R.product_id = M.product_id
where rn = 1
order by 1
;

-- 6. Which item was purchased first by the customer after they became a member?

select * from members;
select * from sales;
select * from menu;


with rnk as(select S.customer_id, product_name, order_date, dense_rank() over(partition by customer_id order by order_date ) rn
from sales S join members M join Menu Me
where S.customer_id = M.customer_id and S.product_id = Me.product_id and
S.order_date >= M.join_date)

select distinct customer_id, product_name, order_date
from rnk
where rn = 1
;

-- 7. Which item was purchased just before the customer became a member?
with rnk as(select S.customer_id, product_name, order_date, dense_rank() over(partition by customer_id order by order_date ) rn
from sales S join members M join Menu Me
where S.customer_id = M.customer_id and S.product_id = Me.product_id and
S.order_date < M.join_date)

select distinct customer_id, product_name, order_date
from rnk
where rn = 1
;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with points as(select *, case 
              when product_id then price*20
              else price*10
          end as Earned_points
          
from menu )

select customer_id, sum(Earned_points) as Earned_points
from Points P join sales S 
on P.product_id = S.product_id
group by 1;         

select * from members;
select * from sales;
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  
  with  W1 as(select *, date_add(join_date, interval 6 day) as valid_date, Last_day("2021-01-31")  as last_date
  from members)
  select S.customer_id, sum(case
                          when Me.product_id = 1 then price*20
                          when S.order_date between w.join_date and w.valid_date then Me.price*20
                          else Me.price*10 end) as Points
from     W1 w join sales S on w.customer_id = S.customer_id join Menu Me
on S.product_id = Me.product_id
where
 S.order_date < last_date   
group by 1
order by 1  ;   

WITH dates AS 
(
   SELECT *, 
   DATE_ADD(join_date, INTERVAL 6 DAY) AS valid_date, 
   LAST_DAY('2021-01-31') AS last_date
   FROM members 
)
Select S.Customer_id, 
       SUM(
	         Case 
		       When m.product_ID = 1 THEN m.price*20
                       When S.order_date between D.join_date and D.valid_date Then m.price*20
                       Else m.price*10
                 END 
           ) as Points
From Dates D
join Sales S
On D.customer_id = S.customer_id
Join Menu M
On M.product_id = S.product_id
Where S.order_date < d.last_date
Group by S.customer_id
ORDER BY S.customer_id;              
  

-- Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

select * from sales;
select * from members;
select * from menu;

SELECT S.customer_id, S.order_date, Me.product_name, Me.price, case 
                                                         when S.order_date >= M.join_date then "Y"
                                                         else "N" 
													 end as Members
                                                     
from  sales S left join menu Me  on S.product_id = Me.product_id
left join members M on S.customer_id = M.customer_id

order by 1;

  
  
  -- Danny also requires further information about the ranking of customer products,
  -- but he purposely does not need the ranking for non-member purchases so he expects null ranking values
  -- for the records when customers are not yet part of the loyalty program.

with MB as(SELECT S.customer_id, S.order_date, Me.product_name, Me.price, case 
                                                         when S.order_date >= M.join_date then "Y"
                                                         else "N" 
													 end as Members
                                                     
from  sales S left join menu Me  on S.product_id = Me.product_id
left join members M on S.customer_id = M.customer_id

order by 1)
  
 select * , case 
               when members = "N" then null
               else dense_rank() over(PARTITION BY customer_id,members ORDER BY order_date)
               
             end as ranking
             
from MB ;            
  
  
  
  
  