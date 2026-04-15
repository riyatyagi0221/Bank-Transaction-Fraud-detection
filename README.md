# Bank Transaction Fraud Detection & Risk Analytics

Project Overview:   
With the rapid growth of digital banking, financial institutions face increasing risks of fraudulent transactions, identity theft, and unauthorized access.    Traditional rule-based systems often fail to detect evolving fraud patterns in real time.    
  
This project builds a data-driven fraud detection and risk analytics system using banking transaction data to:   
*Identify suspicious transaction patterns   
*Analyze behavioral risk signals    
*Enable proactive fraud detection using machine learning    


 Business Problem:    

Banks need to-   
Detect fraudulent transactions early   
Reduce financial losses and false positives    
Improve customer trust and operational efficiency    

 

Dataset:    
50,000+ transactions   
Time range: 2020–2025      
Includes:   
Transaction details (amount, type, timestamp)    
Customer attributes (age, occupation)    
Behavioral signals (login attempts, transaction duration)    
Channel & device data (ATM, Online, Branch)    

   

Key Objectives:    
Perform exploratory data analysis (EDA) to uncover fraud patterns   
Engineer behavioral features for anomaly detection      
Build predictive models to classify fraudulent transactions    
Generate insights for risk-based decision making     
  
 
 Approach & Methodology   
1. Data Cleaning & Preprocessing    
Handled missing values and inconsistencies    
Standardized date-time formats      
Encoded categorical variables    
Created structured datasets for analysis
  

2.. Exploratory Data Analysis (EDA)   
Identified transaction patterns across:   
Channels (ATM, Online, Branch)   
Time (monthly trends)    
Customer segments   
Detected anomalies such as:   
High-value transaction spikes   
Unusual login behavior    
Location/channel inconsistencies    
  
3. Feature Engineering   
Created key fraud indicators:    
Transaction amount bands   
Login risk levels   
Transaction velocity & frequency   
Suspicious transaction flags    
  
4. Machine Learning Models    
Implemented classification models:   
Logistic Regression    
Decision Tree    
Random Forest    
  
5. Risk & Fraud Insights    
Identified high-risk patterns:    
High-value debit transactions with multiple login attempts    
Online channel showing higher fraud exposure   
Behavioral anomalies stronger than static rules   
  
Key Insights   
High-risk transactions are strongly correlated with:  
Multiple login attempts    
High transaction amounts    
Online channels show higher fraud probability compared to physical channels   
Behavioral features outperform basic transaction rules in detecting fraud     


Dashboard & Reporting     
Built interactive dashboards (Tableau):    
Transaction trends over time    
Channel-wise risk distribution    
Fraud detection scatter plots (Amount vs Login Attempts)    
  
KPI tracking:    
Total Transactions   
Suspicious Rate    
Risk Score    
  
Tech Stack    
Python (Pandas, NumPy, Scikit-learn)   
SQL (data transformation & querying)    
Excel (data processing & validation)    
Tableau (dashboarding & reporting)    
  
