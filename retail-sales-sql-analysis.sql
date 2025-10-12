CREATE DATABASE retail_sales_analysis;
USE retail_sales_analysis;
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(10,2)
);
CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_name VARCHAR(50),
    region VARCHAR(30),
    manager VARCHAR(50)
);
CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    store_id INT,
    product_id INT,
    quantity INT,
    total_amount DECIMAL(12,2),
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO products VALUES
(1, 'Laptop', 'Electronics', 75000),
(2, 'Smartphone', 'Electronics', 40000),
(3, 'Headphones', 'Accessories', 3000),
(4, 'T-shirt', 'Apparel', 800),
(5, 'Shoes', 'Apparel', 2500),
(6, 'Refrigerator', 'Appliances', 55000),
(7, 'Microwave', 'Appliances', 15000),
(8, 'Sofa', 'Furniture', 45000),
(9, 'Chair', 'Furniture', 7000),
(10, 'Watch', 'Accessories', 6000);

INSERT INTO stores VALUES
(1, 'UrbanTech', 'North', 'Rajesh Sharma'),
(2, 'CityMart', 'South', 'Priya Verma'),
(3, 'MegaStore', 'East', 'Amit Patel'),
(4, 'ShopSmart', 'West', 'Neha Singh'),
(5, 'ValueHub', 'Central', 'Rohan Das');

INSERT INTO sales VALUES
(1, '2024-01-05', 1, 1, 2, 150000),
(2, '2024-01-08', 2, 2, 3, 120000),
(3, '2024-02-12', 3, 3, 5, 15000),
(4, '2024-02-20', 4, 4, 10, 8000),
(5, '2024-02-28', 5, 5, 4, 10000),
(6, '2024-03-05', 1, 6, 1, 55000),
(7, '2024-03-18', 2, 7, 2, 30000),
(8, '2024-03-22', 3, 8, 1, 45000),
(9, '2024-04-01', 4, 9, 3, 21000),
(10, '2024-04-15', 5, 10, 5, 30000),
(11, '2024-05-02', 1, 2, 4, 160000),
(12, '2024-05-10', 2, 1, 1, 75000),
(13, '2024-06-05', 3, 3, 2, 6000),
(14, '2024-06-12', 4, 4, 6, 4800),
(15, '2024-07-03', 5, 5, 8, 20000),
(16, '2024-07-20', 1, 8, 1, 45000),
(17, '2024-08-02', 2, 9, 2, 14000),
(18, '2024-08-08', 3, 10, 3, 18000),
(19, '2024-09-10', 4, 6, 1, 55000),
(20, '2024-09-20', 5, 7, 2, 30000);

SELECT * FROM products;
SELECT * FROM stores;
SELECT * FROM sales;

#View All Sales Data with Product and Store Details
#Goal: Combine sales, products, and stores into one useful dataset

SELECT 
    s.sale_id,
    s.sale_date,
    st.store_name,
    st.region,
    st.manager,
    p.product_name,
    p.category,
    s.quantity,
    s.total_amount
FROM sales s
JOIN products p ON s.product_id = p.product_id
JOIN stores st ON s.store_id = st.store_id
ORDER BY s.sale_date;

#Find the Top 5 Best-Selling Products by Total Revenue

SELECT 
    p.product_name,
    p.category,
    SUM(s.total_amount) AS total_revenue
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 5;

#Find the Total Sales by Region

SELECT 
    st.region,
    SUM(s.total_amount) AS total_sales
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.region
ORDER BY total_sales DESC;

#Find the Top 3 Store Managers by Sales

SELECT 
    st.manager,
    st.store_name,
    SUM(s.total_amount) AS total_sales
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.manager, st.store_name
ORDER BY total_sales DESC
LIMIT 3;

#Calculate Monthly Sales Trend

SELECT 
    DATE_FORMAT(s.sale_date, '%Y-%m') AS month,
    SUM(s.total_amount) AS monthly_sales
FROM sales s
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY month;

#Find Category-Wise Sales Performance

SELECT 
    p.category,
    SUM(s.total_amount) AS category_sales,
    COUNT(DISTINCT s.sale_id) AS num_transactions
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY category_sales DESC;

#Compute Average Order Value (AOV) by Store

SELECT 
    st.store_name,
    ROUND(AVG(s.total_amount), 2) AS avg_order_value
FROM sales s
JOIN stores st ON s.store_id = st.store_id
GROUP BY st.store_name
ORDER BY avg_order_value DESC;

#Find the Top-Selling Product in Each Region

WITH region_sales AS (
    SELECT 
        st.region,
        p.product_name,
        SUM(s.total_amount) AS revenue
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
    JOIN products p ON s.product_id = p.product_id
    GROUP BY st.region, p.product_name
)
SELECT 
    rs1.region,
    rs1.product_name,
    rs1.revenue
FROM region_sales rs1
WHERE rs1.revenue = (
    SELECT MAX(rs2.revenue)
    FROM region_sales rs2
    WHERE rs2.region = rs1.region
)
ORDER BY rs1.region;

#Find Month-over-Month Sales Growth

WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(sale_date, '%Y-%m') AS month,
        SUM(total_amount) AS total_sales
    FROM sales
    GROUP BY DATE_FORMAT(sale_date, '%Y-%m')
)
SELECT 
    month,
    total_sales,
    LAG(total_sales) OVER (ORDER BY month) AS prev_month_sales,
    ROUND(((total_sales - LAG(total_sales) OVER (ORDER BY month)) / 
           LAG(total_sales) OVER (ORDER BY month)) * 100, 2) AS month_growth_percent
FROM monthly_sales;

#Summary: Overall KPIs

SELECT
    COUNT(DISTINCT sale_id) AS total_transactions,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_transaction_value,
    COUNT(DISTINCT product_id) AS num_products_sold,
    COUNT(DISTINCT store_id) AS num_stores_involved
FROM sales;





























