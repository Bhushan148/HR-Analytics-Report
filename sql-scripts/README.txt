CONSULTING WORKFORCE & HR ANALYTICS - SQL SERVER PROJECT
=========================================================

Purpose
-------
Synthetic learning dataset for a mid-sized consulting / professional-services / BPM-style company.
The model is intentionally compact (5 SQL tables) but includes consulting workforce operations:
service lines, practices, career levels, utilization, billable work, bench, training, promotions,
transfers, salary history, engagement, performance, hiring and attrition.

Important
---------
This is synthetic data. It is not internal data from EY, KPMG, PwC, EXL, Genpact, or any other firm.
It is designed only to resemble common professional-services workforce patterns for learning.

Database
--------
HRAnalytics

SQL Tables
----------
1. DimEmployee
2. DimDepartment
3. DimLocation
4. DimJob
5. FactEmployeeSnapshot

No SQL DimDate table is included. Create the Date dimension in Power BI using DAX.

Fact Grain
----------
One Employee x One Month.

Period
------
2023-10-01 through 2026-09-01 (36 monthly snapshots)

Generated Scale
---------------
Employee dimension rows: 720
Monthly fact rows: 21542
Latest headcount (2026-09-01): 634

Latest Headcount by Service Line
--------------------------------
Technology: 207
Consulting: 174
Business Operations: 122
Risk & Compliance: 72
Internal Corporate Services: 59

Latest Project Status
---------------------
Billable: 435
Internal Project: 77
Bench: 56
Training: 36
Leave: 30

Latest Career Levels
--------------------
Analyst: 115
Consultant: 236
Senior Consultant: 142
Manager: 100
Senior Manager: 36
Director: 5

Files / Recommended Run Order
-----------------------------
01_create_database_and_tables.sql
02_populate_dimensions.sql
03_populate_employees.sql
04_populate_fact_employee_snapshot.sql
05_create_views.sql
06_validation_queries.sql
07_business_analysis_queries.sql

Alternative
-----------
Run HRAnalytics_Full_Setup.sql to create and populate everything in one script.
Then run 06_validation_queries.sql and 07_business_analysis_queries.sql separately.

00_run_all.sql
--------------
Uses SQLCMD :r commands. Enable SQLCMD Mode in SSMS before running it.

Power BI Model
--------------
DimEmployee   1 -> * FactEmployeeSnapshot
DimDepartment 1 -> * FactEmployeeSnapshot
DimLocation   1 -> * FactEmployeeSnapshot
DimJob        1 -> * FactEmployeeSnapshot

Create DimDate in Power BI and relate:
DimDate[Date] 1 -> * FactEmployeeSnapshot[SnapshotDate]

Suggested 2-Page Power BI Story
-------------------------------
Page 1 - Workforce & Utilization Overview
- Active Headcount
- Billable Employees
- Utilization %
- Bench %
- New Hires
- Headcount Trend
- Headcount by Service Line / Practice
- Utilization by Service Line
- Workforce by Career Level
- Billable vs Bench
- Workforce by Location

Page 2 - Talent & Attrition
- Attrition Rate
- Exits
- Promotion Rate
- Average Performance
- Average Engagement
- Attrition by Service Line
- Attrition by Career Level
- Attrition by Tenure
- Bench Exposure vs Attrition
- Utilization vs Attrition
- Performance vs Promotion
- Engagement vs Attrition

Synthetic Design Rules
----------------------
- Employees only receive snapshots from hire month through exit month.
- NewHireFlag and ExitFlag occur only in the corresponding month.
- Most months have MovementType = No Change.
- Promotions move an employee upward in career level and normally increase salary.
- Transfers can change practice and sometimes location.
- Client-facing practices have billable utilization; corporate functions are primarily internal.
- Bench periods reduce utilization and can modestly affect engagement.
- Performance is mostly stable and centered around Meets Expectations.
- Engagement changes gradually rather than randomly jumping each month.
- Salary reviews occur mainly in April, with additional increases on promotion.
- India and USA compensation are stored in local currency and normalized to USD for comparison.
