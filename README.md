# Supply Chain & Sales Data Analysis Dashboard

This project is a complete **Supply Chain & Sales Data Analysis solution** built using **SQL Server** and **Power BI**.  
It demonstrates the full data pipeline starting from a raw CSV file, passing through a **Data Warehouse (Star Schema)**, and ending with an **interactive professional Power BI dashboard**.

This project was developed as part of my **graduation project / digital initiative program**.

---

## 🔹 Project Architecture

The data flow follows this pipeline:

CSV File  
→ Raw Staging Table (SQL Server)  
→ Cleaned View  
→ Data Warehouse (Star Schema)  
→ Power BI Dashboard

---

## 🔹 Technologies Used

- **SQL Server** – Data storage, cleaning, transformation, and data warehouse modeling  
- **Power BI Desktop** – Data visualization and dashboard creation  
- **GitHub** – Version control and project sharing  

---

## 🔹 Data Warehouse Design (Star Schema)

The data warehouse is designed using the **Star Schema** model:

### Dimension Tables:
- `DimProducts`
- `DimSuppliers`
- `DimCustomers`
- `DimShipping`
- `DimTime`

### Fact Table:
- `FactSupplyChain`

All dimension tables are connected to the fact table using **One-to-Many relationships**.

---

## 🔹 Key Performance Indicators (KPIs)

The dashboard includes the following main KPIs:

- Total Revenue  
- Total Cost  
- Total Profit  
- Profit Margin %  
- Total Units Sold  
- Average Shipping Cost  

All KPIs are created using **DAX Measures** and are fully responsive to filters and slicers.

---

## 🔹 Dashboard Pages

The Power BI dashboard contains four main pages:

### 1. Executive Overview
- High-level business performance
- Revenue, Profit, Cost, and Margin
- Revenue by Product Type
- Profit by Supplier
- Revenue by Customer Segment

### 2. Product Performance
- Revenue by SKU
- Profit by SKU
- Product-level performance table

### 3. Suppliers & Shipping
- Profit by Supplier
- Average Shipping Cost by Carrier
- Supplier × Shipping performance matrix

### 4. Customers & Operations
- Revenue by Customer Segment
- Profit by Customer Segment
- Stock Levels vs Products Sold

All pages include **interactive slicers** for dynamic filtering.

---

## 🔹 Repository Contents

- `SQLQuery3-1.sql`  
  → Full SQL script for:
  - Raw data table
  - Data cleaning view
  - Dimension tables
  - Fact table
  - Data loading (ETL)

- `final graduation project.pbix`  
  → Full interactive Power BI dashboard file

---

## 🔹 How to Run the Project

1. Open SQL Server and create a database named:
supply chain


2. Run the SQL script:
SQLQuery3-1.sql


3. Load the CSV file into the raw table (if required).

4. Open: final graduation project.pbix

using **Power BI Desktop**.

5. Refresh the data and explore the interactive dashboard.

---

## 🔹 Key Concepts Applied

- Data Cleaning using SQL Views  
- Data Warehouse Design  
- Star Schema Modeling  
- ETL Process (Extract, Transform, Load)  
- DAX Measures  
- Interactive Power BI Dashboards  

---

## 🔹 Author

**Field:** Data Analysis  
**Program:** Digital Egypt Initiative / Graduation Project  

---

✅ This project demonstrates my ability to work with real-world data, build a complete data warehouse, and create professional business intelligence dashboards.
