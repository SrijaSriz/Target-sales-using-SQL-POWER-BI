# 🛒 Target Sales Data Analytics | MySQL Project

## 📌 Objective

Design a scalable MySQL data pipeline and derive actionable insights from the Target Sales dataset by performing relational joins, complex aggregations, window functions, and optimizing queries through indexes and stored procedures.

---

## 🔧 Database Design & ETL

* Structured **7 relational tables**: `Customers`, `Orders`, `Products`, `Payments`, `Order_Items`, `Sellers`, and `Geolocation` using MySQL DDL.
* Established **foreign key relationships** to ensure referential integrity.
* Loaded over **180,000+ records** from real-world e-commerce retail data into MySQL.

---

## 📊 Business Insights & Query Highlights

### 1️⃣ Revenue Analysis by Month & Payment Type

* Built **CTE-based monthly revenue dashboard** using `JOIN`, `GROUP BY`, and `RANK() OVER()` for top payment methods.
* Found that **credit cards dominate monthly revenue**, followed by boleto and debit payments.

### 2️⃣ Most Sold Product Categories

* Identified **top 10 best-selling product categories** by aggregating order items and joining with product data.
* Helps stakeholders understand which categories drive the most sales volume.

### 3️⃣ Delivery Delay Analysis

* Using `DATEDIFF`, flagged all customers with **late deliveries**.
* Insight: Over 5,000 orders were **delivered past the estimated date**, affecting customer satisfaction.

### 4️⃣ Sellers with Highest Freight Charges

* Created a **temporary table** to find sellers contributing most to freight costs.
* Business Use: Optimize logistics or re-evaluate seller partnerships.

### 5️⃣ Customer Lifetime Value (CLV)

* Aggregated total orders and payment value per unique customer.
* Key Insight: Top 20 customers contributed **significantly to revenue**, a base for loyalty programs.

---

## ⚡ Optimization & Scalability

* **Indexing** for query performance:

  * `orders(customer_id)`
  * `order_items(product_id)`
  * `payments(order_id)`

* Designed a **Stored Procedure** `GetOrderSummary()` to fetch end-to-end order details with one call — simulating a real-world order summary endpoint.

```sql
CALL GetOrderSummary('47770eb9100c2d0c44946d9cf07ec65d');

## 🧰 Tools Used

* **MySQL 8.0+**
* **MySQL Workbench / CLI**
* **E-commerce retail dataset** (Target-style sales)

---

## 📈 Real-World Applications

* Can be extended into **Power BI dashboards**, **API reporting tools**, or **automated reporting scripts**.
* Ideal for companies like Amazon, Flipkart, Target to **track customer behavior, seller performance, and delivery efficiency**.

---

## 📁 Project Structure

```
Target_Sales_MySQL_Project/
├── schema_creation.sql
├── data_load_instructions.md
├── queries/
│   ├── insights.sql
│   ├── stored_procedures.sql
│   └── optimization_indexing.sql
├── README.md
```

---

## 🚀 Next Steps

* Integrate with **Power BI / Excel Dashboards**
* Extend analysis with **Python + Pandas notebooks**
* Deploy interactive dashboards using **Streamlit** or **Flask**
