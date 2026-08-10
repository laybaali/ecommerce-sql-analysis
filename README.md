# E-Commerce Customer, Seller & Logistics Analysis

## Project Overview

This project analyzes a real-world e-commerce marketplace dataset to uncover insights across business performance, customer behavior, seller dynamics, and delivery operations using  MySQL and Python .

The goal is to simulate real-world business analysis by answering practical questions such as:

- How is revenue evolving over time?
- Which regions and product categories drive revenue?
- How valuable and loyal are customers?
- Is revenue dependent on a small group of sellers?
- What operational factors influence delivery performance?
- Do delivery delays impact high-value orders?

The project combines  Python-based data preparation  with  SQL-driven analytical problem solving , and includes visualizations to communicate key business insights.

---

## Business Objectives

The analysis is structured into four key areas:

### 1. Business Performance
- Revenue trends over time
- Geographic revenue distribution
- Product category performance
- Order volume and average order value

### 2. Customer Analytics
- Customer retention and repeat behavior
- Customer lifetime value (CLV)
- Revenue concentration across customers
- RFM segmentation for business-driven customer grouping

### 3. Seller Analytics
- Seller contribution to revenue
- Seller concentration and dependency risk
- Order volume distribution across sellers
- Marketplace structure (single vs multi-seller orders)

### 4. Logistics Analytics
- On-time vs delayed delivery performance
- Delivery duration analysis
- Impact of product characteristics (e.g., weight) on delivery time
- Delivery performance across order types
- Revenue exposure to delivery delays

---

## Tools & Technologies

-  Python 
  - Pandas
  - NumPy
  - Jupyter Notebook
  - Matplotlib (for visualization)

-  SQL 
  - MySQL
  - Joins, Aggregations, Subqueries
  - Window Functions
  - CASE Statements
  - CTEs
  - Date Functions

-  Version Control 
  - Git & GitHub

---

## Dataset

This project uses the  Brazilian E-Commerce Public Dataset (Olist) :

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

The dataset contains ~100K orders and includes:

- Orders
- Customers
- Payments
- Order items
- Products
- Sellers
- Reviews
- Product categories
- Geographic data

---

## Project Structure
ecommerce-sql-analysis/
│
├── README.md
├── data_model.sql
│
├── queries/
│ ├── 01_business_overview.sql
│ ├── 02_customer_analysis.sql
│ ├── 03_seller_analysis.sql
│ └── 04_logistics_analysis.sql
│
├── notebooks/
│ ├── data_cleaning.ipynb
│ └── visualization.ipynb
│
├── outputs/
│ └── charts/
│ ├── on_time_vs_delayed_orders.png
│ ├── weight_vs_delivery_time.png
│ ├── delay_rate_by_order_type.png
│ └── revenue_by_delivery_status.png
│
└── insights.md


---

## Notebooks

### data_cleaning.ipynb
- Data inspection and quality checks
- Handling missing values and duplicates
- Data type validation
- Creation of analysis-ready datasets
- Aggregation of payment data into `payments_summary`

### visualization.ipynb
- Connects to MySQL database
- Executes SQL queries using `pandas.read_sql()`
- Generates business-focused charts
- Saves outputs to `/outputs/charts`

---

## Key Analysis Highlights

### Business Performance
- Revenue trends reveal overall business growth patterns
- A small number of product categories contribute a large share of revenue
- Geographic concentration highlights key markets driving sales

### Customer Analytics
- Majority of customers are one-time buyers
- Revenue is concentrated among a smaller high-value segment
- RFM segmentation identifies:
  - Champions
  - Loyal Customers
  - At-Risk High-Value Customers
  - Lost Customers

### Seller Analytics
- Marketplace shows  seller concentration , where a small percentage contributes a large portion of revenue
- Long-tail distribution of seller activity
- Multi-seller orders form a smaller but important segment of transactions

### Logistics Insights
- ~92% of orders are delivered on time, indicating strong operational performance
- Delivery time increases consistently with product weight
- Multi-seller orders surprisingly show  lower delay rates  than single-seller orders
- Delayed orders contribute significant revenue, highlighting potential customer experience risk

---

## Visual Insights

The project includes key visualizations:

-  On-Time vs Delayed Orders 
-  Product Weight vs Delivery Time 
-  Delay Rate by Order Type (Single vs Multi-Seller) 
-  Revenue by Delivery Status 

These charts help translate SQL analysis into clear business insights.

---

## Key Takeaways

- Revenue and customer value are  highly concentrated 
- Seller ecosystem shows  dependency risk on top performers 
- Logistics performance is strong but not uniform across scenarios
- Product characteristics (like weight) directly influence operations
- Delivery delays impact both  customer experience and revenue exposure 

---

## Future Improvements

- Add dashboard (Power BI / Tableau)
- Incorporate customer review sentiment analysis
- Predict delivery delays using machine learning
- Build cohort retention analysis

---

## Conclusion

This project demonstrates end-to-end analytical thinking:

- Data cleaning and preparation in Python  
- Business problem solving using SQL  
- Translating data into insights and visualizations  

It reflects how data analysts approach real-world business problems in e-commerce environments.
