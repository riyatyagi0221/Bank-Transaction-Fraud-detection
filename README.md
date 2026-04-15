# Bank-Transaction-Fraud-detection

Project Overview
This project analyzes 50,000 real-world bank transactions from 495 customer accounts (2020–2025). The goal was to transform raw transactional data into actionable business intelligence while ensuring data integrity, security (fraud detection), and system performance.


Tech Stack
SQL (MYSQL): Advanced querying, Window Functions, CTEs, and Performance Tuning.
Python (Pandas, Scipy, Matplotlib): Exploratory Data Analysis (EDA) and Statistical Hypothesis Testing.
Power BI: Star schema modeling and interactive DAX dashboards.
Excel: Data auditing and stakeholder reporting.
kaggle: Data Source (Bank Transactions Dataset for Fraud Detection)

Key Features & Analysis
Instead of relying on visual trends, I utilized Python to perform:
T-Tests & ANOVA: Confirmed that transaction behaviors vary significantly across different occupation segments ($p=0.0007$).
Value at Risk (VaR): Calculated historical risk thresholds (95% and 99%) for Online vs. ATM channels.
2. Advanced SQL Logic
Fraud Detection: Created a composite risk score using CTEs to flag accounts with high login failures and suspicious transaction amounts.
Customer Lifetime Value (CLV): Applied Window Functions and NTILE to segment customers based on 5-year spending habits.
Performance Tuning: Optimized query speeds by 40% through strategic indexing and avoiding "anti-patterns" (like SELECT *).


Key Business Insights
High-Risk Alerts: 3.85% of transactions were identified as high-risk due to excessive login attempts (potential credential stuffing).
Channel Preference: Branch transactions still account for the highest volume (34.6%), while Online transactions show the highest growth rate.
Demographic Value: Customers aged 40–64 (Gen X/Boomers) hold the majority of "Premium" accounts ($10k+ balance).

