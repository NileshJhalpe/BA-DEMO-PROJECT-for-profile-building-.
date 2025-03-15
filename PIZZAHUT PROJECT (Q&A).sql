CREATE DATABASE pizzahut;
Use pizzahut;

SELECT * FROM pizzas;
SELECT * FROM pizza_types;

CREATE TABLE orders (
order_id INT NOT NULL,
order_date DATE NOT NULL,
order_time TIME NOT NULL,
primary key (order_id)
);

SELECT * FROM orders;

CREATE TABLE order_details ( 
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id TEXT NOT NULL,
quantity INT NOT NULL,
primary key (order_details_id)
);

SELECT * FROM order_details;

-- Basic:
-- Retrieve the total number of orders placed.
-- Calculate the total revenue generated from pizza sales.
-- Identify the highest-priced pizza.
-- Identify the most common pizza size ordered.
-- List the top 5 most ordered pizza types along with their quantities.


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
-- Determine the distribution of orders by hour of the day.
-- Join relevant tables to find the category-wise distribution of pizzas.
-- Group the orders by date and calculate the average number of pizzas ordered per day.
-- Determine the top 3 most ordered pizza types based on revenue.

-- Advanced:
-- Calculate the percentage contribution of each pizza type to total revenue.
-- Analyze the cumulative revenue generated over time.
-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.


-- BASIC
 -- 1-- Retrieve the total number of orders placed.
 SELECT * FROM orders;
 SELECT count(order_id) FROM orders;
 SELECT count(order_id) AS total_orders FROM orders;
 
 
 -- 2-- Calculate the total revenue generated from pizza sales.
 SELECT * FROM pizzas;
 SELECT * FROM order_details;
  
SELECT 
SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM order_details JOIN pizzas
ON pizzas.pizza_id = order_details.pizza_id;

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;


--  3 -- Identify the highest-priced pizza.
    SELECT * FROM pizzas;
    SELECT * FROM pizza_types;
    
    
    SELECT pizza_types.name, pizzas.price
    FROM pizza_types JOIN pizzas
    ON pizza_types.pizza_type_id = pizzas.pizza_type_id
	ORDER BY pizzas.price DESC LIMIT 1;
 
 -- 4-- Identify the most common pizza size ordered.
 SELECT * FROM order_details;
 SELECT * FROM pizzas; 
 
 SELECT quantity, count(order_details_id) 
 FROM order_details group by quantity;
 
 
 SELECT pizzas.size, count(order_details.order_details_id) AS order_count
 FROM pizzas join order_details
 ON pizzas.pizza_id = order_details.pizza_id
 GROUP BY pizzas.size ORDER BY order_count DESC;
 
 
 -- 5-- List the top 5 most ordered pizza types along with their quantities.
   SELECT * FROM order_details;
   SELECT * FROM pizzas;
   SELECT * FROM pizza_types;
 
 
 SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- Intermediate:
-- 6-- Join the necessary tables to find the total quantity of each pizza category ordered.

     SELECT * FROM order_details;
     SELECT * FROM pizzas;
    SELECT * FROM pizza_types;

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7-- Determine the distribution of orders by hour of the day.
SELECT * FROM orders;

SELECT 
    HOUR(order_time) AS HOUR, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT * FROM pizza_types;


SELECT category,count(name) FROM pizza_types
GROUP BY category;


-- 9-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT * FROM orders;
SELECT * FROM order_details;

SELECT 
    ROUND(AVG(quantity), 0) AS avg_pizza_ordered_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;


-- 10-- Determine the top 3 most ordered pizza types based on revenue.

     SELECT * FROM order_details;
     SELECT * FROM pizzas;
    SELECT * FROM pizza_types;
    
    
SELECT pizza_types.name,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM pizza_types join pizzas
ON pizzas.pizza_type_id = pizza_types.pizza_type_id
JOIN order_details 
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name ORDER BY revenue DESC LIMIT 3;


-- Advanced:
-- 11-- Calculate the percentage contribution of each pizza type to total revenue.


SELECT pizza_types.category,
SUM(order_details.quantity*pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category ORDER BY revenue DESC;


SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 12-- Analyze the cumulative revenue generated over time.


SELECT order_date,
SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT orders.order_date,
SUM(order_details.quantity * pizzas.price) AS revenue
FROM order_details JOIN pizzas
ON order_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = order_details.order_id
GROUP BY orders.order_date) AS sales;


-- 13-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue FROM
(SELECT category, name, revenue,
RANK () OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
(SELECT pizza_types.category, pizza_types.name,
SUM((order_details.quantity) * pizzas.price) AS revenue
FROM pizza_types JOIN pizzas
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details
ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;



