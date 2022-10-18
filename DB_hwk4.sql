-----------------------------------------------------------------------------------------------
SELECT customerName,  addressLine1, addressLine2, city, state, postalCode 
FROM customers 
WHERE salesRepEmployeeNumber IS NULL
ORDER BY customerName
-----------------------------------------------------------------------------------------------
SELECT customerName, creditLimit 
FROM customers
WHERE creditLimit >100000 AND creditLimit <= 200000
ORDER BY customerName
-----------------------------------------------------------------------------------------------
SELECT firstName, lastName
FROM employees
WHERE firstName GLOB "M*" AND lastName GLOB "P*"
OR firstName GLOB "P*" AND lastName GLOB "M*"
ORDER BY lastName
-----------------------------------------------------------------------------------------------
SELECT DISTINCT productName
FROM (((products NATURAL JOIN orderdetails) 
NATURAL JOIN orders) NATURAL JOIN customers)
WHERE customerName = "Mini Wheels Co."
ORDER BY productLine
-----------------------------------------------------------------------------------------------
WITH 
tmp AS(
		SELECT lastName as cLast, firstName as cFirst
		FROM employees)
SELECT DISTINCT customerName
FROM customers NATURAL JOIN tmp
WHERE tmp.cFirst = contactFirstName OR tmp.cLast = contactLastName
ORDER BY customerName
-----------------------------------------------------------------------------------------------
WITH 
    tmp AS(
		SELECT  min(quantityInStock) AS least
		FROM products)
SELECT productCode, productName
FROM products NATURAL JOIN tmp
WHERE tmp.least = quantityInStock 
-----------------------------------------------------------------------------------------------
WITH
    tmp AS(
        SELECT  officeCode, count(officeCode) AS numEmps
        FROM employees
        GROUP BY officeCode),
    least AS( 
        SELECT min(numEmps) AS mins, max(numEmps) AS maxes
        FROM tmp),
    minAndMaxEmployees AS(	
        SELECT officeCode, numEmps 
        FROM tmp NATURAL JOIN least 
        WHERE least.mins = numEmps OR least.maxes = numEmps)
SELECT numEmps, city
FROM offices NATURAL JOIN minAndMaxEmployees
WHERE minAndMaxEmployees.officeCode = officeCode 
ORDER BY numEmps, city
-----------------------------------------------------------------------------------------------
WITH
    tmp AS(
        SELECT  salesRepEmployeeNumber, count(salesRepEmployeeNumber) AS numClients
        FROM customers
        WHERE salesRepEmployeeNumber IS NOT NULL
        GROUP BY salesRepEmployeeNumber),
    salesReps AS(
        SELECT lastName, firstName, numClients, officeCode
        FROM employees NATURAL JOIN tmp
        WHERE tmp.salesRepEmployeeNumber = employeeNumber
        ORDER BY  numClients DESC)
SELECT firstName, lastName, city, numClients
FROM offices NATURAL JOIN salesReps
-----------------------------------------------------------------------------------------------
WITH
    tmp AS (
        SELECT  customerNumber, sum(amount) AS totalPayment
        FROM payments
        GROUP BY customerNumber)
SELECT customerNumber, customerName, totalPayment
FROM customers NATURAL JOIN tmp
ORDER BY totalPayment
-----------------------------------------------------------------------------------------------
WITH
	tmp AS(
		SELECT productCode, productName, orderNumber
		FROM products NATURAL JOIN orderdetails
		GROUP BY orderNumber)	,
	productsOrdered AS (
	SELECT customerNumber, productCode, productName, orderNumber
	FROM tmp NATURAL JOIN orders
	GROUP BY productCode
	),
	allProducts AS (
		SELECT productCode, productName, customerName 
		FROM customers JOIN products
		ORDER BY customerName, productCode
		)
SELECT  productCode, productName, customerName 
FROM allProducts WHERE productCode NOT IN 
(SELECT productCode FROM productsOrdered)
ORDER BY customerName, productCode

-----------------------------------------------------------------------------------------------
SELECT productName, 
(MSRP * quantityInStock) - (buyPrice * quantityInStock) as profit
FROM products
GROUP BY productName
ORDER BY profit
-----------------------------------------------------------------------------------------------
WITH
	qPerOrderNum AS(
		SELECT orderNumber, sum(quantityOrdered) as orderQ
		FROM orderdetails
		GROUP BY orderNumber),
	customersWhoOrdered AS(
		SELECT customerNumber, customerName, orderQ
		FROM orders NATURAL JOIN qPerOrderNum NATURAL JOIN customers
		)
SELECT customerName, avg(orderQ) AS averageQuantity
FROM customersWhoOrdered
GROUP BY customerName
ORDER BY customerName
-----------------------------------------------------------------------------------------------