# 1. What is the total amount each customer spent at the restaurant?

SELECT s.customer_id, SUM(price) as total_amt
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY customer_id
ORDER BY total_amt desc;

# 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(order_date) as total_days
FROM sales
group by customer_id
ORDER BY total_days desc;

# 3. What was the first item from the menu purchased by each customer?

WITH CTE1 as
(
SELECT s.customer_id, m.product_name, order_date,
       row_number() over(partition by customer_id order BY order_date ) as row_num
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id) 
SELECT customer_id, product_name
 FROM CTE1 
 WHERE row_num = 1;
 
 #5.  What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT m.product_name, count(order_date) as no_of_times
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY no_of_times desc
LIMIT 1;

# 6. Which item was the most popular for each customer?
WITH CTE as
(
SELECT s.customer_id, m.product_name, COUNT(order_date) as order_cnt,
	row_number() over(partition by customer_id order by count(order_date) desc) as rnk
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id 
GROUP BY s.customer_id, m.product_name)
SELECT customer_id,product_name,order_cnt
FROM CTE
WHERE rnk = 1;

# 7.Which item was purchased first by the customer after they became a member?
WITH x as
(
SELECT s.customer_id, m.product_name, s.order_date, mb.join_date,
       rank() over (partition by customer_id order by order_date) as rnk
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
JOIN members mb 
ON mb.customer_id = s.customer_id
WHERE order_date>join_date
)
SELECT customer_id,product_name
FROM x
WHERE rnk = 1;

# 8. Which item was purchased just before the customer became a member?

WITH x as
(
SELECT s.customer_id, m.product_name, s.order_date, mb.join_date,
       rank() over (partition by customer_id order by order_date desc) as rnk
FROM sales s 
JOIN menu m
ON s.product_id = m.product_id
JOIN members mb 
ON mb.customer_id = s.customer_id
WHERE order_date<join_date
)
SELECT customer_id,product_name
FROM x
WHERE rnk = 1;

# 9. What is the total items and amount spent for each member before they became a member?

SELECT s.customer_id,COUNT(product_name) as total_items, SUM(price) as amt_spend
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
JOIN members mb
ON s.customer_id = mb.customer_id
WHERE order_date<join_date
GROUP BY s.customer_id
ORDER BY s.customer_id;

# 10.If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT s.customer_id,
sum(CASE
    WHEN product_name = 'sushi' THEN price*10*2
    ELSE price*10
    END) as points
FROM sales s 
JOIN menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id;

# 11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
 #not just sushi - how many points do customer A and B have at the end of January?
 
 SELECT s.customer_id, m.product_name, s.order_date, m.price,
       CASE
        WHEN product_name = 'sushi' THEN m.price*2
        WHEN order_date BETWEEN mb.join_date AND DATE_ADD(join_date, INTERVAL 6 DAY) THEN m.price*2
        ELSE m.price
        END as points
 FROM sales s 
 JOIN menu m 
 ON s.product_id = m.product_id
JOIN members mb 
ON s.customer_id = mb.customer_id
WHERE DATE_FORMAT(order_date, '%y-%m-01') = '2021-01-01';


