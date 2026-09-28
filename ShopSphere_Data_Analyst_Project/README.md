# ShopSphere — Customer Retention & Revenue Analytics

## Business Problem
ShopSphere wants to understand revenue performance, customer retention, product performance and revenue leakage caused by cancellations and returns.

## Dataset
- 5,000 customers
- 100 products
- 21,065 orders
- 1,609 return records
- 5,000 marketing/customer acquisition records

## Tech Stack
- SQL / SQLite
- Python / Pandas
- Power BI
- DAX
- HTML/CSS/JavaScript
- Chart.js

## Key KPIs
- Revenue: ₹185,681,863
- Orders: 21,065
- Customers: 5,000
- AOV: ₹9,313
- Repeat Purchase Rate: 89.8%
- Return Rate: 7.6%
- Cancellation Rate: 5.4%
- Estimated Profit: ₹41,551,718

## How to run the dashboard
1. Open `dashboard/index.html` through a local HTTP server.
2. Example: `python -m http.server 8000 --directory dashboard`
3. Visit `http://localhost:8000`.

## SQL
The SQLite database is in `database/shopsphere.db`.
Run the queries in `sql/analysis.sql`.

## Power BI
Use `powerbi/powerbi_guide.md` to recreate the model and measures in Power BI.

## Project Workflow
Raw data → Cleaning → SQL → Customer/RFM analysis → Data model → Dashboard → Business insights → Recommendations

## Future Improvements
- Add automated refresh
- Connect to a cloud database
- Add customer cohort matrix
- Add marketing ROI
- Add row-level security
- Publish to Power BI Service
