--Monday Coffee Analysis
SELECT * FROM Coffee.City;
SELECT * FROM Coffee.Customers;
SELECT * FROM Coffee.products;
SELECT * FROM Coffee.Sales;

--REPORT AND ANALYSIS

--QUE.1 Coffee Customers Count in each city, given that 25% of population does?
SELECT
	city_name,
	CAST(population * 0.25/ 1000000 AS decimal(10,2)) AS CoffeeConsumersInMillions
	FROM Coffee.City
	ORDER BY CoffeeConsumersInMillions DESC;


--QUE.2 Total revenue from coffee sales across all cities in last quarter?
SELECT
	ci.city_name,
	SUM(s.total) as TotalRevenue
	FROM Coffee.Sales as s
	JOIN coffee.Customers c
	ON s.customer_id = c.customer_id
	JOIN coffee.City as ci
	ON ci.city_id = c.city_id
WHERE
	YEAR(s.sale_date)= 2023
	AND
	DATEPART(QUARTER, s.sale_date) = 4 
GROUP BY ci.city_name
ORDER BY SUM(s.total) DESC;

--QUE.3 How many unit of each coffee product have been sold?

SELECT
p.product_name,
COUNT(s.product_id) AS TotalUnitsSold
FROM Coffee.Products AS p
LEFT JOIN Coffee.Sales as s
ON s.product_id=p.product_id
GROUP BY p.product_name
ORDER BY COUNT(s.product_id) DESC;

-- QUE.4 Average sales amount per customer in each city?

WITH CTE_CustomerTotals AS 
(
		SELECT 
		c.customer_id,
		ci.city_name,
		SUM(s.total) AS Total_sales_per_customer
		FROM Coffee.Sales as s
	JOIN coffee.Customers c
	ON s.customer_id = c.customer_id
	JOIN coffee.City as ci
	ON ci.city_id = c.city_id
GROUP BY c.customer_id,
		ci.city_name
)
	SELECT
		city_name,
		AVG(Total_sales_per_customer) AS AvgSalesPerCustomer
		FROM CTE_CustomerTotals
		GROUP BY city_name
		ORDER BY AvgSalesPerCustomer DESC;

--QUE.5  what are the top 3 selling products in each city on sales volume?

SELECT *
FROM 
(
	SELECT
		ci.city_name,
		p.product_name,
		COUNT(s.sale_id) AS TotalOrders,
		ROW_NUMBER() OVER(PARTITION BY ci.city_name ORDER BY COUNT(s.sale_id) DESC) AS Rank
	FROM Coffee.Sales as s
	JOIN coffee.Customers c
	ON s.customer_id = c.customer_id
	JOIN coffee.City as ci
	ON ci.city_id = c.city_id
	JOIN Coffee.products AS p
	ON s.product_id= p.product_id
	GROUP BY ci.city_name,
			p.product_name
) AS t1
WHERE Rank<=3;

--QUE.6 Find each city and their average sales per customer and avg rent per customer 

SELECT
	ci.city_name,
	COUNT(DISTINCT c.customer_id) AS TotalDistCustomers,
	CAST(SUM(s.total) * 1.0 /
	COUNT(DISTINCT c.customer_id) AS decimal(15,2)) AS AvgSalesPerCustomer,
	CAST(AVG(ci.estimated_rent) * 1.0 /
	COUNT(DISTINCT c.customer_id) AS decimal(15,2)) AS AvgRentPerCustomer
		FROM coffee.city AS ci
		JOIN Coffee.customers AS c
		ON c.city_id = ci.city_id
		JOIN Coffee.sales AS s
		ON s.customer_id= c.customer_id
	GROUP BY ci.city_name;

--QUE.7 Calculate the percentage growth or decline in sales over diffrent time period(monthly) by each city

WITH 
	CTE_MonthlySales AS
	(
		SELECT 
			ci.city_name,
			SUM(s.total) AS TotalSales,
			FORMAT(s.sale_date,'yyyy-MM') AS SalesMonth
		FROM coffee.city AS ci
			JOIN Coffee.customers AS c
			ON c.city_id = ci.city_id
			JOIN Coffee.sales AS s
			ON s.customer_id= c.customer_id
		GROUP BY ci.city_name,
				FORMAT(s.sale_date,'yyyy-MM')
	),
	CTE_SalesWithLag AS
	(
		SELECT
		city_name,
		TotalSales,
		SalesMonth,
		LAG(TotalSales) OVER(PARTITION BY city_name ORDER BY SalesMonth) AS PreviousMonthSales
		FROM CTE_MonthlySales
	)
	SELECT
		city_name,
		TotalSales,
		SalesMonth,
		PreviousMonthSales,
		CASE
			WHEN PreviousMonthSales IS NULL THEN NULL
			WHEN PreviousMonthSales=0 THEN NULL
		ELSE
			CAST((((TotalSales-PreviousMonthSales) * 100.0)/ PreviousMonthSales) AS decimal(18,2))
		END AS PercentageGrowth
	FROM CTE_SalesWithLag
	ORDER BY city_name,
			SalesMonth,
			PercentageGrowth;

--QUE.8 Identify top 3 cities based on highest sales, return city name, total sales, total rent, total customers and Avg Rent per customer.
 
	WITH CTE_SalesData AS
	(
		SELECT 
		ci.city_name,
		ci.estimated_rent AS TotalRent,
		SUM(s.total) AS TotalSales,
		COUNT(DISTINCT c.customer_id) AS TotalCustomers,
		CAST((ci.estimated_rent * 1.0)/ 
		COUNT(DISTINCT c.customer_id) AS DECIMAL(18,2)) AS AvgRentPerCustomer
		FROM coffee.city AS ci
				JOIN Coffee.customers AS c
				ON c.city_id = ci.city_id
				JOIN Coffee.sales AS s
				ON s.customer_id= c.customer_id
				GROUP BY city_name,
						ci.estimated_rent
	),
	CTE_RankedSales AS
	(
		SELECT 
		city_name,
		TotalSales,
		TotalCustomers,
		AvgRentPerCustomer,
		TotalRent,
		RANK() OVER (ORDER BY TotalSales DESC) AS RankedOnSales
		FROM CTE_SalesData
	)
		SELECT
		city_name,
		TotalSales,
		TotalCustomers,
		TotalRent,
		AvgRentPerCustomer,
		RankedOnSales
		FROM CTE_RankedSales
		WHERE RankedOnSales <= 3;
		

 ------------------------------------------------------------------------------------------------------------------------
 --A QUESTION FOR OVERALL ANALYSIS:

 --Which are the cities comapny should prioratize based on total sales, customer base, average sales per customer and city rent?

 	WITH CTE_SalesData AS
	(
		SELECT 
		ci.city_name,
		ci.estimated_rent AS TotalRent,
		SUM(s.total) AS TotalSales,
		COUNT(DISTINCT c.customer_id) AS TotalCustomers,
		CAST((SUM(s.total) * 1.0) /
		COUNT(DISTINCT c.customer_id) AS DECIMAL(18,2)) AS AvgSalesPerCustomer,
		CAST((ci.estimated_rent * 1.0)/ 
		COUNT(DISTINCT c.customer_id) AS DECIMAL(18,2)) AS AvgRentPerCustomer
		FROM coffee.city AS ci
				JOIN Coffee.customers AS c
				ON c.city_id = ci.city_id
				JOIN Coffee.sales AS s
				ON s.customer_id= c.customer_id
				GROUP BY city_name,
						ci.estimated_rent
	),
	CTE_RankedSales AS
	(
		SELECT 
		city_name,
		TotalSales,
		TotalCustomers,
		AvgSalesPerCustomer,
		AvgRentPerCustomer,
		TotalRent,
		RANK() OVER (ORDER BY TotalSales DESC) AS RankedOnSales
		FROM CTE_SalesData
	)
		SELECT
		city_name,
		TotalSales,
		TotalCustomers,
		TotalRent,
		AvgSalesPerCustomer,
		AvgRentPerCustomer,
		RankedOnSales
		FROM CTE_RankedSales
		WHERE RankedOnSales <= 10;

/*RECOMMENDATION SUMMARY:
	Based on the overall sales performance, customer engagement and rent , these are the top 3 recommended cities:

	1. PUNE
		-Highest total sales
		-Highest average sales per customer
		-Lowest rent per Customer

	2. CHENNAI
		-Strong total and average sales
		-Overall rent cosyt is still reasonable 

	3. BANGALORE
		-Overall good sales and customer base
		-Rent cost is slightly higher but still profitable due to higher customer value
*/
