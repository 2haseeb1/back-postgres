-- Active: 1742865201516@@127.0.0.1@5000@bookstore_db
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

/* output:
bookstore_db=# SELECT * FROM books;
 id |           title            |      author      | price | stock | published_year
----+----------------------------+------------------+-------+-------+----------------
  2 | Clean Code                 | Robert C. Martin | 35.00 |     5 |           2008
  3 | You Don't Know JS          | Kyle Simpson     | 30.00 |     8 |           2014
  5 | Database Design Principles | Jane Smith       | 20.00 |     0 |           2018
  1 | The Pragmatic Programmer   | Andrew Hunt      | 40.00 |    10 |           1999
  4 | Refactoring                | Martin Fowler    | 50.00 |     3 |           1999
(5 rows) */


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

-- It means this query selects the title column from the books table where the stock is equal to 0, it indicates that books  are currently unavailable.

-- It means when run on your table, it returns "Database Design Principles" because its stock is 0, when  all the other books have stock greater than 0.

-- Query 2: Retrieve the most expensive book
SELECT * FROM books ORDER BY price DESC LIMIT 1;

/* It means this query retrieves all columns (*) from the books table and sorts the rows by the price column in descending order (DESC), so the highest price comes first.

using this LIMIT 1 ensures only the top row—the book with the highest price—is returned from the sorted list. */

-- Query 3: Find total number of orders per customer
SELECT c.name, COUNT(o.id) AS total_orders 
FROM customers c 
INNER JOIN orders o ON c.id = o.customer_id 
GROUP BY c.name;


/* It means this query selects the name column from the customers table (aliased as c) and

 counts the number of order IDs (o.id) from the orders table to show how many orders each customer has placed, labeling the result as total_orders.

 the INNER JOIN means to combine rows from customers and orders where the customer’s id matches the customer_id in the orders table, it deducted customers like Charlie who have no orders.

 the GROUP BY c.name organizes the results so that all orders for each customer are grouped together, allowing COUNT(o.id) to calculate the total orders per customer name.

It shows the data, which outputs "Alice | 2" and "Bob | 1" because Alice has two orders and Bob has one, while Charlie is omitted due to having no orders.
 */


-- Query 4: Calculate total revenue from book sales
SELECT SUM(b.price * o.quantity) AS total_revenue 
FROM orders o 
JOIN books b ON o.book_id = b.id;

/* To figure out the total revenue, we use the shared ID between the orders table and the books table. This ID allows us to link each order's book ID to the corresponding book's price.
 For each order, we multiply the book's price by the quantity sold. Then, we sum up all these individual order revenues. The resulting total represents the overall revenue generated from book sales, as shown by the SQL command: SELECT SUM(b.price * o.quantity) AS total_revenue FROM orders o JOIN books b ON o.book_id = b.id;
 */

-- Query 5: List customers with more than one order
SELECT c.name, COUNT(o.id) AS orders_count 
FROM customers c 
JOIN orders o ON c.id = o.customer_id 
GROUP BY c.name 
HAVING COUNT(o.id) > 1;


/*

To find out those  customers who’ve bought books more than once, this query looks at two lists: the customers table with names and the orders table with order details, matching them up by customer IDs using JOIN orders o ON c.id = o.customer_id. It counts how many orders each customer has with COUNT(o.id), groups them by name with GROUP BY c.name, and then uses HAVING COUNT(o.id) > 1 to keep only those with more than one order—like Alice with 2 orders, while Bob with 1 gets left out. With your data, it shows just "Alice | 2" in the result as name | orders_count, since she’s the only repeat buyer, perfectly matching the sample output.

So, the result highlights our best customers who keep coming back, giving their names and order counts in a quick, easy way! */

-- Query 6: Find average price of books
SELECT ROUND(AVG(price), 2) AS avg_book_price 
FROM books;

/* Here to find the average price of all the books in our store. To do this, we use a simple  command: SELECT ROUND(AVG(price), 2) AS avg_book_price FROM books;.

First, the computer looks at our list of books and their prices. Then, it adds up all the prices. After that, it divides the total by the number of books. This gives us the average price.

The ROUND(AVG(price), 2) part of the command makes sure the answer is rounded to two decimal places, so it looks like '35.00'. This final number, which we call 'avg_book_price', tells us the typical price of a book in our store. It's a quick way to get that average, straight from our book price list. */

-- Query 7: Increase price of books published before 2000 by 10%
UPDATE books 
SET price = price * 1.10 
WHERE published_year < 2000;

/* Suppose now  we want to update our book price list. So  We've decided to increase the prices of older books, specifically those published before the year 2000, by 10%.

Here's how the computer does it:

UPDATE books: This tells the computer we want to change something in the 'books' list (table).

SET price = price * 1.10: This part indicates, 'For each book we're changing, take its current price and multiply it by 1.10 (which is the same as increasing it by 10%)'. So, if a book was $10, it will now be $11.
WHERE published_year < 2000: This is the filter. It says, 'Only do this price increase for books where the 'published_year' is less than 2000'. This ensures only the older books would be changed.
In short, this query goes through the 'books' list, finds all the books published before 2000, and increases their prices by 10%. It's a nice way to automatically update prices based on a specific condition. */

-- Query 8: Delete customers who haven’t placed any orders
DELETE FROM customers 
WHERE id NOT IN (SELECT customer_id FROM orders);


/* In this case our task is to delete that customer's ID data who did not order anything in the orders table.

To remove the customers who never placed an order is a very easy task with this query: it checks the customers table and zaps anyone whose ID doesn’t show up in the orders table! It uses DELETE FROM customers to target rows, and the WHERE id NOT IN (SELECT customer_id FROM orders) part acts like a filter—it looks at the orders table, sees customer_id values 1 (Alice) and 2 (Bob), and keeps only those customers, ditching anyone else. So, with your data, Charlie (ID 3) gets the boot because he’s not in the orders table at all, while Alice and Bob stay since they’ve got orders (Alice with 2, Bob with 1).


It’s a neat little cleanup—no fancy joins, just a subquery to spot the no-shows! After running this, your customers table shrinks from three rows to two, showing just "Alice | alice@email.com | 2023-01-10" and "Bob | bob@email.com | 2022-05-15," exactly like the sample output expects. It’s a quick way to trim the list down to active buyers!  */

/* bookstore_db=# SELECT * FROM customers;
 id |  name   |       email       | joined_date
----+---------+-------------------+-------------
  1 | Alice   | alice@email.com   | 2023-01-10
  2 | Bob     | bob@email.com     | 2022-05-15
  3 | Charlie | charlie@email.com | 2023-06-20
(3 rows)

bookstore_db=# SELECT * FROM orders;
 id | customer_id | book_id | quantity |     order_date
----+-------------+---------+----------+---------------------
  1 |           1 |       2 |        1 | 2024-03-10 00:00:00
  2 |           2 |       1 |        1 | 2024-02-20 00:00:00
  3 |           1 |       3 |        2 | 2024-03-05 00:00:00
(3 rows)

after deletion for the customers TABLE using this command 

DELETE FROM customers 
WHERE id NOT IN (SELECT customer_id FROM orders);

bookstore_db=# SELECT * FROM customers;
 id | name  |      email      | joined_date
----+-------+-----------------+-------------
  1 | Alice | alice@email.com | 2023-01-10
  2 | Bob   | bob@email.com   | 2022-05-15
(2 rows) */


SELECT * FROM customers;
SELECT * FROM books;


SELECT title FROM books WHERE stock = 0

SELECT * FROM customers;
SELECT * FROM orders;

