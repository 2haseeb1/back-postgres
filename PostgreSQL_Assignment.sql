-- Create the books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) CHECK (price >= 0) NOT NULL,
    stock INTEGER NOT NULL,
    published_year INTEGER NOT NULL
);

-- Create the customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    joined_date DATE DEFAULT CURRENT_DATE
);

-- Create the orders table
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    book_id INTEGER REFERENCES books(id),
    quantity INTEGER CHECK (quantity > 0) NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data into books
INSERT INTO books (title, author, price, stock, published_year) VALUES
('The Pragmatic Programmer', 'Andrew Hunt', 40.00, 10, 1999),
('Clean Code', 'Robert C. Martin', 35.00, 5, 2008),
('You Don''t Know JS', 'Kyle Simpson', 30.00, 8, 2014),
('Refactoring', 'Martin Fowler', 50.00, 3, 1999),
('Database Design Principles', 'Jane Smith', 20.00, 0, 2018);

-- Insert sample data into customers
INSERT INTO customers (name, email, joined_date) VALUES
('Alice', 'alice@email.com', '2023-01-10'),
('Bob', 'bob@email.com', '2022-05-15'),
('Charlie', 'charlie@email.com', '2023-06-20');

-- Insert sample data into orders
INSERT INTO orders (customer_id, book_id, quantity, order_date) VALUES
(1, 2, 1, '2024-03-10'),
(2, 1, 1, '2024-02-20'),
(1, 3, 2, '2024-03-05');

-- Query 1: Find books that are out of stock
SELECT title FROM books WHERE stock = 0;

-- Query 2: Retrieve the most expensive book
SELECT * FROM books ORDER BY price DESC LIMIT 1;

-- Query 3: Find total number of orders per customer
SELECT c.name, COUNT(o.id) AS total_orders 
FROM customers c 
LEFT JOIN orders o ON c.id = o.customer_id 
GROUP BY c.name;

-- Query 4: Calculate total revenue from book sales
SELECT SUM(b.price * o.quantity) AS total_revenue 
FROM orders o 
JOIN books b ON o.book_id = b.id;

-- Query 5: List customers with more than one order
SELECT c.name, COUNT(o.id) AS orders_count 
FROM customers c 
JOIN orders o ON c.id = o.customer_id 
GROUP BY c.name 
HAVING COUNT(o.id) > 1;

-- Query 6: Find average price of books
SELECT ROUND(AVG(price), 2) AS avg_book_price 
FROM books;

-- Query 7: Increase price of books published before 2000 by 10%
UPDATE books 
SET price = price * 1.10 
WHERE published_year < 2000;

-- Query 8: Delete customers who haven’t placed any orders
DELETE FROM customers 
WHERE id NOT IN (SELECT customer_id FROM orders);