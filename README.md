# SQL Case Study # - Danny's Diner
#### ![Danny's Diner](https://github.com/user-attachments/assets/4057eff8-3847-435e-9af6-853ead99e840)
## 📚 Table of Contents
- Business Task
- Entity Relationship Diagram
- Questions & Solutions
---
Please note that all the information regarding the case study has been sourced from the following link: [here](https://8weeksqlchallenge.com/case-study-1/)
# Business Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite.
Danny has shared 3 key datasets for this case study:
- sales
- menu
- members
# Entity Relationship Diagram
![Danny](https://github.com/user-attachments/assets/50bbab53-c565-4357-8834-1db749ca7fc4)
# Questions & Solutions
#### 1. What is the total amount each customer spent at the restaurant?
#### Solution:-
```
SELECT
         customer_id,
         SUM(price) AS Total_spent
FROM
         sales JOIN menu
WHERE 
         sales.product_id=menu.product_id
GROUP BY
         customer_id;
```
#### Output:-

<img width="279" height="133" alt="Screenshot 2025-11-15 113339" src="https://github.com/user-attachments/assets/0150a4c2-9140-41f1-b193-d80fa23008c5" />

- Customer A spent $152
- Customer B spent $148
- Customer C spent $72
---
#### 2. How many days has each customer visited the restaurant?
#### Solution:-
```
SELECT
          customer_id,
          COUNT(DISTINCT order_date) AS COUNT_OF_DAYS
FROM
          sales 
GROUP BY
          customer_id;
```
### Output:-
![Ans 2](https://github.com/user-attachments/assets/479128fa-0ff0-45d6-905a-c42638251e60)
- Customer A has visited the restaurant 4 days.
- Customer B has visited the restaurant 6 days.
- Customer C has visited the restaurant 2 days.
---
  
#### 3. What was the first item from the menu purchased by each customer?
#### Solution:-
```
WITH CALCULATE AS (
SELECT
       customer_id,
       product_name,
       order_date,
       DENSE_RANK() over(partition by customer_id order by order_date) AS RANKS
FROM
       sales JOIN menu
WHERE
       sales.product_id=menu.product_id
GROUP BY
        customer_id,
        product_name,
        order_date
)
SELECT
       customer_id,
       product_name
FROM
       CALCULATE
WHERE
       RANKS=1
```
#### Output:-
![Ans 3](https://github.com/user-attachments/assets/89802568-f19e-4046-902c-e9a3af9441c9)
- Customer A placed an order for both curry and sushi simultaneously, making them the first items in the order.
- Customer B's first order is curry.
- Customer C's first order is ramen.
---
#### 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
#### Solution:- 
```
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
```
- **2nd Solution**
```
select product_name, count(S.product_id) as sale_count
from sales S join menu M 
where S.product_id = M.product_id
group by 1
order by 2 desc
limit 1;
```

#### Output:-

<img width="258" height="56" alt="Screenshot 2025-11-15 141654" src="https://github.com/user-attachments/assets/4b81ca02-214a-4b31-b46b-b5dfef119950" />

- **Ramen is the item that was purchased the most by all customers and it was purchased 16 times.**
---
#### 5. Which item was the most popular for each customer?
#### Solution:- 
```
WITH RANKING AS (
SELECT
         customer_id,
         product_name,
         COUNT(sales.product_id) AS count_of_products,
         DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(sales.product_id) DESC) AS RANKS
FROM
         sales JOIN menu
WHERE
         sales.product_id=menu.product_id
GROUP BY
         customer_id,
         product_name
)
SELECT
      customer_id,
      count_of_products,
      product_name
FROM
      RANKING
WHERE
      RANKS=1;
```



#### Output:-
![Ans 4 1](https://github.com/user-attachments/assets/a28219c0-cf9f-43bf-b83e-b741de5d5bad)
- For both the customers A and C, ramen was the most popular item.
- For customer B, all the three items were equally popular which are curry, sushi and ramen.
---
#### 6. Which item was purchased first by the customer after they became a member?
#### Solution:- 
```
WITH RANKING AS (
SELECT
       sales.customer_id,
       order_date,
       product_name,
       DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS RANKS
FROM
       sales JOIN menu JOIN members
WHERE
       sales.product_id=menu.product_id AND
       sales.customer_id=members.customer_id AND
       sales.order_date >= members.join_date
)
SELECT
       customer_id,
       product_name,
       order_date
FROM
       RANKING
WHERE
       RANKS=1;
```

### Output:-
![Ans 6](https://github.com/user-attachments/assets/a369b56f-5bf3-43d0-bcd5-0c97d560197b)
- After becoming a member, A's first order was curry.
- After becoming a member, B's first order was sushi.
---
#### 7. Which item was purchased just before the customer became a member?
#### Solution:- 
```
WITH RANKING AS (
SELECT
       sales.customer_id,
       order_date,
       product_name,
       DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date DESC) AS RANKS
FROM
       sales JOIN menu JOIN members
WHERE
       sales.product_id=menu.product_id AND
       sales.customer_id=members.customer_id AND
       sales.order_date < members.join_date
)
SELECT
       customer_id,
       product_name,
       order_date
FROM
       RANKING
WHERE
       RANKS=1;
```
#### Output:-
![Ans 7](https://github.com/user-attachments/assets/6b77c0bc-1657-4edb-9e0d-d973b502c542)
- Just before becoming a member, A purchased 2 items sushi and curry.
- Just before becoming a member, B purchased sushi.
---
#### 8. What is the total items and amount spent for each member before they became a member?
#### Solution:-
```
SELECT
           sales.customer_id,
           COUNT(sales.product_id) AS product_count,
           SUM(price) AS total_spent
FROM
           sales JOIN menu JOIN members 
WHERE
           sales.customer_id=members.customer_id AND
           sales.product_id=menu.product_id AND
           order_date < join_date
GROUP BY
           sales.customer_id
ORDER BY
           sales.customer_id;
```
#### Output:-
![Ans 8](https://github.com/user-attachments/assets/4844cbb2-ca51-4e46-b8e0-9636697ef39d)
Before becoming members,
- Customer A spent $25 on 2 items.
- Customer B spent $40 on 3 items.
---
#### 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
#### Solution:-
```
WITH POINTS AS (
SELECT
        *,
        CASE
            WHEN product_id=1 THEN price*20
            ELSE price*10
        END AS total_points
FROM
        menu
)
SELECT
         customer_id,
         SUM(total_points)
FROM
         sales JOIN points
WHERE
         sales.product_id=points.product_id
GROUP BY
         customer_id;
```
#### Output:-
![Ans 9](https://github.com/user-attachments/assets/86fa1c12-0187-4a13-8555-b9c7f83de27c)
- Total points for Customer A is $860.
- Total points for Customer B is $940.
- Total points for Customer C is $360.
---
#### 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
#### Solution:-
```
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
```
#### Output:-
![Ans 10](https://github.com/user-attachments/assets/2ad667e0-ad23-4997-a489-6b75065b7ed7)
- Total points for Customer A is 1,370.
- Total points for Customer B is 820.
---
## Bonus Questions
#### Join All The Things
#### Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)
#### Solution:-
```
SELECT
         S.customer_id,
         S.order_date,
         M.product_name,
         M.price,
         CASE
              WHEN order_date >= join_date THEN "Y"
              ELSE "N" 
         END AS member
FROM
         sales S LEFT JOIN menu M
ON   
         S.product_id=M.product_id LEFT JOIN members MB
ON
         S.customer_id=MB.customer_id
ORDER BY
         S.customer_id,
         S.order_date;
```
#### Output:-
![Ans 11](https://github.com/user-attachments/assets/62464c85-119b-4e59-a71d-feeb2037c551)

---

#### Rank All The Things

#### Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

#### Solution:-
```
WITH membership AS (
SELECT
         S.customer_id,
         S.order_date,
         M.product_name,
         M.price,
         CASE
              WHEN order_date >= join_date THEN "Y"
              ELSE "N" 
         END AS member
FROM
         sales S LEFT JOIN menu M
ON   
         S.product_id=M.product_id LEFT JOIN members MB
ON
         S.customer_id=MB.customer_id
ORDER BY
         S.customer_id,
         S.order_date
)
SELECT
        customer_id,
        order_date,
        product_name,
        price,
        member,
        CASE
             WHEN member = "N" THEN null
             ELSE DENSE_RANK() OVER (PARTITION BY customer_id,member ORDER BY order_date)
        END AS ranking
FROM
        membership
```
#### Output:-

![Ans 12](https://github.com/user-attachments/assets/4b78c711-bb15-472c-8203-50440772cf77)

---
