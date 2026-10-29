# Brazilian E-Commerce Sales Performance Analysis

### Project Overview
This project analyzes the Brazilian E-Commerce Public Dataset by Olist to evaluate sales performance, order status, and delivery performance.
The goal is to identify top-performing product categories, understand monthly sales trends, analyze order cancellations, and evaluate delivery performance across customer states.

### Tools Used:
PostgreSQL, SQL, Power BI, and DAX

### Key Metrics: 
Delivered Item Sales, Delivered Orders, Average Order Value, Cancellation Rate, Average Delivery Time, and Delivery Delay.

### Business Problem
An e-commerce business needs to understand its sales performance, order cancellations, and delivery efficiency to make better business decisions. However, raw transactional data alone does not clearly show sales trends, leading product categories, or differences in delivery performance.
This project uses SQL and Power BI to analyze e-commerce data and identify useful business insights.

### Project Objectives
-   Analyze total delivered item sales, delivered orders, and average order value.
-   Identify the top-performing product categories by sales.
-   Analyze monthly sales trends and identify the peak sales month.
-   Examine order statuses and calculate the order cancellation rate.
-   Calculate average delivery time and delivery delay.
-   Compare delivery performance across customer states.
-   Build an interactive Power BI dashboard to communicate the findings.

### Dataset

#### Dataset Name: 
Brazilian E-Commerce Public Dataset by Olist

#### Source:
Kaggle

The dataset contains Brazilian e-commerce order information, including orders, customers, products, sellers, payments, and reviews. These data tables support analysis of sales performance, order status, and delivery performance.

### Tools and Technologies
 - PostgreSQL: Stored and queried the dataset using SQL.
 - SQL: Performed data quality checks, sales analysis, category ranking, monthly trend analysis, customer analysis, and delivery performance analysis.
 - Power BI: Built a two-page report to visualize sales performance, order status, and delivery metrics.
 - DAX: Created measures for delivered item sales, delivered orders, average order value, average delivery time, average delivery delay, and cancellation rate.

### Project Workflow
1. Loaded the dataset files into PostgreSQL.
2. Checked data quality and analyzed the data using SQL queries.
3. Created relationships between relevant tables in Power BI.
4. Developed DAX measures and validated key metrics against SQL results.
5. Built a two-page Power BI report to present the findings.

### Key Results and Business Insights
#### 1. Sales Performance
- The top three product categories by sales were Health & Beauty, Watches & Gifts, and Bed, Bath & Table.
- November 2017 recorded the highest monthly sales in the analysis.
- Delivered item sales totaled R$13,221,498.11 across 96,478 delivered orders.
- Average order value was R$137.04.

#### 2. Order Cancellation Analysis
- The dataset contained 625 canceled orders.
- The overall order cancellation rate was 0.63%.
- Further analysis of cancellation reasons could help identify opportunities to reduce cancellations.

#### 3. Delivery Performance
- Average delivery time was approximately 12.6 days, based on the validated SQL calculation.
- Average delivery delay was -11.2 days, indicating that delivered orders arrived earlier than their estimated delivery dates on average.
- Alagoas (AL) had an average delivery delay of -8.0 days.

### Business Recommendations
- Investigate sales patterns around November to better understand potential seasonal demand.
- Monitor top-performing product categories to support inventory and sales planning.
- Analyze cancellation reasons to identify potential improvements in order fulfillment.
- Compare delivery performance across states to identify regional differences and improve delivery estimates.

### Power BI Dashboard
The report contains two pages:

#### Page 1: Sales Performance Overview
This page presents key sales KPIs, monthly sales trends, top-performing product categories, and sales by customer state.
<img width="1312" height="746" alt="sales_performance_overview" src="https://github.com/user-attachments/assets/562ee7be-d087-429a-91cd-c9dd63deda4f" />



#### Page 2: Order and Delivery Analysis
This page presents order counts by status, average delivery time, average delivery delay by customer state, and the overall order cancellation rate.
<img width="1297" height="741" alt="order_delivery_analysis" src="https://github.com/user-attachments/assets/ee8400ad-13aa-4c63-8593-0236b1d3e676" />

### SQL Analysis

The SQL analysis was organized into three files:
- #### 01_data_quality.sql:
  Data quality checks and validation of the dataset.
- #### 02_sales_analysis.sql:
  Sales KPIs, monthly sales trends, product category performance, and customer-state sales analysis.
- #### 03_advanced_analysis.sql:
  Advanced analysis, including customer behavior, rankings, segmentation, delivery delays, and category contribution.

The SQL queries use techniques such as:
- Aggregate functions (SUM, COUNT, AVG)
- Joins across related tables
- Conditional aggregation using CASE
- Common Table Expressions (CTEs)
- Window functions such as RANK() and DENSE_RANK()
- Date and time calculations

### Conclusion
This project demonstrates how SQL and Power BI can be used together to analyze e-commerce performance, validate business metrics, and communicate findings through an interactive dashboard.





