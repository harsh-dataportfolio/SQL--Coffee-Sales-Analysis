# Coffee Sales Analysis using SQL  
A data-driven SQL project that uncovers actionable business insights from a coffee sales dataset using structured queries and analysis.

---

##  Project Overview  
This project aims to analyze coffee sales data across various cities to provide insights into revenue trends, product performance, Average sales, and city-wise profitability. The analysis was conducted using SQL queries within SQL Server Management Studio (SSMS), leveraging a real-world dataset sourced from Kaggle.

---

##  Project Objectives  
- Analyze total revenue generated from coffee sales in the last quarter across all cities.  
- Identify the number of units sold for each coffee product.  
- Calculate average sales per customer in each city.  
- Determine city-wise average sales and rent per customer.  
- Measure percentage growth or decline in monthly sales by city.  
- Identify and recommend the top 3 performing cities based on a combination of revenue, customer base, and rent costs.

---

##  Dataset Used  
**Name**: Coffee Sales Dataset  
**Source**: [Kaggle.com](https://www.kaggle.com)  
**Description**:  
This dataset includes 4 diffrent files/tables :
- City  
- Customer  
- Product  
- Sales  

---

## 🛠 Tools Used  
- **SQL Server Management Studio (SSMS)**: For writing and executing SQL queries.  

---

##  Key Insights  
Based on the analysis, the following are the top 3 cities:

1. **Pune**  
   - Highest total sales  
   - Highest average sales per customer  
   - Lowest rent per customer  
   → **Top city to prioritize**

2. **Chennai**  
   - Strong total and average sales  
   - Rent is reasonable and profitable  
   → **Recommended for strategic focus**

3. **Bangalore**  
   - Good overall sales and customer base  
   - Rent is slightly higher but offset by high customer value  
   → **Still a profitable target city**

---

##  Final Recommendation: Top 3 Cities (Query Output)

The image below shows the output of the final SQL query that analyzes total sales, average sales per customer, customer base, and rent to identify the top 3 cities for business focus.

![Top 3 Cities Query Output](results/top_3_cities_output.png)

