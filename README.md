# Consulting Workforce & HR Analytics | Power BI

A Power BI portfolio project focused on **workforce analytics, resource utilization, bench management, talent movement, engagement, performance, and attrition** in a consulting / professional-services environment.

The project uses a synthetic workforce dataset and follows a realistic BI workflow from a curated SQL Server model through Power Query, semantic modeling, DAX, validation, security, version control, and Power BI Service publishing.

**Live Power BI Report:** [View Interactive Dashboard](https://app.fabric.microsoft.com/view?r=eyJrIjoiNWVmYjhkNDYtYmJjNS00MDA5LTkwOWMtOTZiZDMyNjRhNTEyIiwidCI6ImQ4ZTFiMDVlLTcwYWEtNGVmNy1iODc4LTQ2NmI2ODhmOTUyZiJ9)

**GitHub Repository:** [hr-analytics-github](https://github.com/Bhushan148/hr-analytics-github)

> The public report is shared for portfolio demonstration only. All employee and workforce data in this project is synthetic.

---

## Project Overview

The purpose of this project was to build a workforce analytics solution that goes beyond a basic HR headcount dashboard. The report combines traditional HR metrics with consulting-specific operational metrics such as billable workforce, utilization, bench exposure, target utilization, and workforce capacity.

The reporting period covers **October 2023 to September 2026**, using a monthly employee snapshot model that makes it possible to analyze both the current workforce position and historical workforce movement.

### Project Summary

| Area | Details |
|---|---|
| Domain | HR Analytics / Workforce Analytics / Consulting Operations |
| Reporting Tool | Microsoft Power BI |
| Data Source | Microsoft SQL Server (`HRAnalytics`) |
| Reporting Period | Oct 2023 – Sep 2026 |
| Workforce History | 720 employees |
| Fact Table | 21,542 employee-month records |
| Latest Headcount | 634 employees |
| Fact Grain | One employee × one monthly snapshot |
| DAX Measures | 28 |
| Security | Dynamic RLS using Country × Service Line access |
| Project Format | PBIP + TMDL |
| Version Control | Git + Azure Repos / GitHub |

---

## Business Problem

A consulting workforce needs to be viewed from two connected perspectives: **people** and **capacity**.

The report was designed to answer questions such as:

- How is the workforce changing over time?
- How is headcount distributed across Service Lines, Practices, locations, and career levels?
- How many client-facing employees are billable?
- How does actual utilization compare with expected utilization?
- Where is bench capacity concentrated?
- Which Service Lines and career levels show higher attrition?
- At what tenure stages are employees leaving?
- How are engagement and performance distributed across the workforce?
- How are promotions and internal movements changing over time?
- What does the current career-level structure look like?

The result is a combined **HR + Workforce + Resource Utilization** reporting solution rather than a standalone HR dashboard.

---

## Solution Architecture

```text
SQL Server — HRAnalytics
        │
        ▼
Power Query
(parameters, data checks, helper columns, incremental refresh)
        │
        ▼
Power BI Semantic Model
(star schema + DAX date table)
        │
        ▼
DAX Measures
(headcount, utilization, bench, attrition, talent metrics)
        │
        ▼
Power BI Report
(Overview + Talent & Attrition analysis)
        │
        ▼
Dynamic Row-Level Security
(Country × Service Line)
        │
        ▼
Power BI Service
(publishing, refresh and report access)
```

---

## Dataset

The model represents a mid-sized consulting workforce operating across **India and the USA**.

### Main Tables

| Table | Rows | Purpose |
|---|---:|---|
| `DimEmployee` | 720 | Employee and employment attributes |
| `DimDepartment` | 19 | Service Line, Practice and client-facing classification |
| `DimLocation` | 6 | City, region, country and office information |
| `DimJob` | 51 | Job title, career level, job family and utilization target |
| `FactEmployeeSnapshot` | 21,542 | Monthly workforce, utilization, talent and movement data |
| `SecurityUserAccess` | Mapping table | User access by Country × Service Line |
| `DimDate` | DAX table | Calendar and time analysis |

### Service Lines

- Consulting
- Technology
- Risk & Compliance
- Business Operations
- Internal Corporate Services

### Locations

**India:** Pune, Mumbai, Bengaluru, Hyderabad  
**USA:** New York, Austin

### Career Levels

```text
Analyst
  ↓
Consultant
  ↓
Senior Consultant
  ↓
Manager
  ↓
Senior Manager
  ↓
Director
```

---

## Data Model

The Power BI model uses a **star schema** with `FactEmployeeSnapshot` at the center.

```text
                         DimDate
                            │
                            ▼
DimDepartment ─────► FactEmployeeSnapshot ◄───── DimLocation
                            ▲           ▲
                            │           │
                       DimEmployee    DimJob

SecurityUserAccess
(disconnected security mapping table)
```

All analytical relationships use **one-to-many cardinality** with single-direction filtering from dimensions to the fact table.

### Fact Table Grain

The fact table is stored at:

> **One employee × one monthly snapshot**

This grain is important because workforce metrics behave differently depending on whether they represent a **point in time** or a **period of activity**.

For example:

- Current Headcount, Billable Employees, Bench Employees and Utilization are evaluated at the latest visible month.
- New Hires, Exits, Promotions and Transfers accumulate across the selected period.

This prevents the same employee from being incorrectly counted multiple times when a user selects several months.

### Power BI Data Modeling

The reporting model was completed in Power BI as a semantic layer on top of the curated SQL Server tables. The goal was to keep the model simple, predictable, and suitable for both business reporting and security.

Key modeling work included:

- creating relationships from `DimEmployee`, `DimDepartment`, `DimLocation`, `DimJob`, and `DimDate` to `FactEmployeeSnapshot`;
- using **one-to-many** relationships with **single-direction filtering** from dimensions to the fact table;
- keeping the model in a **star schema** instead of importing the flattened SQL validation view as the reporting model;
- creating `DimDate` in DAX and marking it as the model's Date table;
- creating Year, Quarter, Month, Year-Month, and numeric sort columns for consistent time navigation;
- using dedicated sort columns for business categories such as Tenure Band and Engagement Category;
- keeping technical keys and helper fields hidden from the report view where they are not needed by end users;
- organizing the 28 measures in a dedicated `_Measures` table and grouping them into business-focused display folders;
- keeping `SecurityUserAccess` disconnected from the normal analytical relationships so it is used only for Dynamic RLS authorization;
- validating relationship behavior and filter propagation before building final visuals.

The monthly snapshot design was also reflected in the measure layer. Current-state measures use the latest visible snapshot, while movement metrics such as hires, exits, promotions, and transfers are evaluated across the selected reporting period.

This separation between the physical SQL model and the Power BI semantic model keeps the reporting layer easier to maintain and makes the metric definitions more consistent across visuals.

---

## Power Query

Power Query is used mainly for reporting preparation while the core dimensional structure remains in SQL Server.

### Parameters

- `SqlServer`
- `SqlDatabase`
- `RangeStart`
- `RangeEnd`

Using connection parameters makes the model easier to maintain across environments without rewriting individual queries.

### Incremental Refresh

`FactEmployeeSnapshot` is configured to:

- retain five years of historical data;
- refresh the most recent three months;
- use `SnapshotDate >= RangeStart` and `SnapshotDate < RangeEnd` for clean partition boundaries.

### Reporting Helper Columns

Power Query also creates several reporting-focused fields, including:

- `SnapshotMonthKey`
- `UtilizationRatio`
- `OverUtilizedFlag`
- `NonBillableHours`
- `TenureBandSort`
- `EngagementCategorySort`

---

## DAX & KPI Design

The semantic model contains **28 DAX measures** grouped by business area.

### Headcount

- Current Headcount
- Average Monthly Headcount
- Prior Month Headcount
- Headcount MoM %
- Latest Visible Snapshot Date

### Consulting Operations

- Current Client-Facing Headcount
- Billable Employees
- Billable Share %
- Current Utilization %
- Target Utilization %
- Utilization vs Target
- Bench Employees
- Bench Rate %
- Average Bench Days
- Training Hours

### Workforce Movement

- New Hires
- Exits
- Promotions
- Transfers
- Attrition Rate %
- Promotion Rate %
- Average Exit Tenure

### Talent

- Average Performance
- Average Engagement
- High Performers
- Low Engagement Employees

### Calculation Approach

A few design choices were especially important in this model:

**Point-in-time vs period measures**  
Current-state KPIs are anchored to the latest visible snapshot, while workforce movement measures are calculated across the selected period.

**Weighted utilization**  
Utilization is calculated as total billable hours divided by total available hours rather than averaging individual utilization percentages.

**Business-specific denominators**  
Bench and utilization metrics use the client-facing workforce, while workforce movement rates use average monthly headcount where appropriate.

---

## Report Pages

The report contains four pages, with two main analytical pages supported by navigation and drill-through functionality.

### Home

A simple landing page that provides navigation into the analytical report.

### Workforce & Utilization Overview

The main operational page focuses on current workforce position and consulting capacity.

It includes:

- Current Headcount
- Billable Employees
- Billable Share
- Current vs Target Utilization
- Bench Employees and Bench Rate
- Workforce trend
- Hires and exits over time
- Service Line distribution
- Location distribution
- Career-level distribution

### Talent & Attrition Insights

This page focuses on workforce movement and retention analysis.

It includes:

- New Hires
- Exits
- Attrition Rate
- Promotions
- Transfers
- Average Exit Tenure
- Attrition by Service Line
- Attrition by Career Level
- Exit reasons
- Tenure at exit
- Engagement analysis
- Performance analysis
- Promotion patterns
- Bench exposure analysis

### Drill Through

A detail page used to investigate selected groups without overloading the main report pages.

---

## Key Results

### Latest Snapshot — September 2026

| KPI | Result |
|---|---:|
| Current Headcount | **634** |
| Client-Facing Headcount | **575** |
| Billable Employees | **435** |
| Billable Share | **75.7%** |
| Current Utilization | **64.2%** |
| Target Utilization | **79.5%** |
| Utilization Gap | **-15.3 pp** |
| Bench Employees | **56** |
| Bench Rate | **9.7%** |
| Average Bench Days | **17.5** |
| Average Engagement | **66.4** |
| High Performers | **281** |
| Low Engagement Employees | **196** |

### Workforce Movement — 36 Months

| Metric | Result |
|---|---:|
| New Hires | **160** |
| Exits | **95** |
| Promotions | **144** |
| Transfers | **45** |
| Average Exit Tenure | **38.2 months** |
| 36-Month Cumulative Attrition Rate | **15.9%** |
| Latest Rolling 12-Month Attrition Rate | **6.9%** |

---

## Key Findings

The report surfaced several useful patterns in the synthetic workforce data:

- Headcount increased from **562 to 634** across the reporting period, representing approximately **12.8% growth**.
- Current client-facing utilization is **64.2%** against a weighted target of **79.5%**.
- Technology has the largest current bench population, with **23 of 56 bench employees**.
- Consulting has the highest 36-month Service Line attrition rate at **18.8%**.
- Consultants account for **40 of the 95 exits**, making this the largest exit population by career level.
- Compensation, better opportunities and career growth together represent approximately **63% of recorded exit reasons**.
- Employees observed in the Low Engagement group show a higher exit rate than employees observed in the High Engagement group.
- The current workforce is concentrated at Consultant and Senior Consultant levels, creating a more diamond-shaped career structure than a traditional pyramid.

These findings are presented as descriptive analytics from the project dataset rather than causal conclusions.

---

## Dynamic Row-Level Security

The semantic model includes **Dynamic Row-Level Security (RLS)** so different users can access the same report while seeing only their permitted workforce scope.

The security grain is:

> **User × Country × Service Line**

`SecurityUserAccess` stores the approved combinations, and `USERPRINCIPALNAME()` identifies the signed-in user.

This design preserves exact combinations. For example, a user permitted to see:

```text
India + Consulting
USA   + Technology
```

is not automatically given access to:

```text
India + Technology
USA   + Consulting
```

The mapping table remains disconnected from the standard analytical relationships and is referenced only by the RLS logic.

The public dashboard link in this repository is intended only as a portfolio demonstration using synthetic data; the RLS design is part of the semantic-model implementation and testing workflow.

---

## Validation

The model was validated against SQL queries before finalizing the report metrics.

### Data Quality Checks

Checks include:

- table row counts;
- monthly snapshot coverage;
- duplicate Employee × Month records;
- snapshots outside employee hire / exit dates;
- hire and exit flag consistency;
- bench flag and project-status consistency;
- utilization range checks;
- dimensional distributions.

### KPI Reconciliation

| KPI | Power BI | SQL | Status |
|---|---:|---:|---|
| Current Headcount | 634 | 634 | Matched |
| Billable Employees | 435 | 435 | Matched |
| Bench Employees | 56 | 56 | Matched |
| Service Line Headcount | 207 / 174 / 122 / 72 / 59 | Same | Matched |
| Career-Level Headcount | 115 / 236 / 142 / 100 / 36 / 5 | Same | Matched |

For utilization, the final report uses the defined weighted client-facing calculation rather than a simple average of row-level utilization percentages.

---

## Source Control

The Power BI solution is maintained as a **Power BI Project (PBIP)** rather than only as a binary `.pbix` file. PBIP stores the report and semantic-model definitions as text-based project files, including the model definition in **TMDL**, which makes the Power BI work suitable for Git-based source control.

### Repository Workflow

```text
Power BI Desktop
      ↓
PBIP / TMDL project files
      ↓
Local Git repository
      ↓
Azure Repos — primary development repository
      ↓
GitHub — public portfolio mirror
```

Source control was used to keep a traceable history of changes across the report, semantic model, SQL scripts, and project documentation. Instead of maintaining multiple files such as `Report_Final_v2.pbix` and `Report_Final_v3.pbix`, changes are captured through Git commits and can be reviewed at file level.

The source-control setup includes:

- **Azure Repos** as the primary development repository;
- **GitHub** as the public showcase mirror for the completed portfolio project;
- PBIP/TMDL files so report and model changes can be versioned as text;
- structured commits for model, DAX, report, security, and documentation updates;
- branch / merge workflow suitable for reviewing Power BI changes before integrating them into the main branch;
- SQL scripts and documentation stored alongside the Power BI project so the full solution is reproducible from one repository.

This setup reflects a team-oriented BI development workflow where report changes can be tracked, reviewed, compared, and rolled back instead of being managed only through manually renamed Power BI files.

---

## Power BI Service Deployment

After the report, semantic model, calculations, validation, and security logic were finalized, the solution was published to **Power BI Service**.

The service-side workflow covered:

- publishing the report and semantic model to the Power BI workspace;
- configuring the SQL Server connection and refresh settings;
- applying the incremental-refresh policy to the monthly snapshot fact table;
- assigning approved users to the `Dynamic_RLS` role;
- validating representative security personas in Power BI Service;
- checking report and semantic-model permissions;
- promoting the solution through controlled environments / deployment workflow;
- sharing the completed report with the intended audience through Power BI Service.

The live public report linked at the top of this README is the portfolio-facing version built on synthetic data.

---

## Tech Stack

| Area | Technology |
|---|---|
| Database | Microsoft SQL Server |
| Data Preparation | Power Query |
| Data Modeling | Power BI Semantic Model |
| Calculations | DAX |
| Reporting | Microsoft Power BI |
| Security | Dynamic Row-Level Security |
| Project Format | PBIP + TMDL |
| Version Control | Git |
| Development Repository | Azure Repos |
| Portfolio Repository | GitHub |
| Publishing | Power BI Service |

---

## SQL Components

```text
sql-scripts/
│
├── 00_run_all.sql
├── 01_create_database_and_tables.sql
├── 02_populate_dimensions.sql
├── 03_populate_employees.sql
├── 04_populate_fact_employee_snapshot.sql
├── 05_create_views.sql
├── 06_validation_queries.sql
├── 07_business_analysis_queries.sql
├── 08_create_rls_security_mapping.sql
└── README.txt
```

Two supporting SQL views are used for validation and analysis:

- `vw_EmployeeSnapshotEnriched`
- `vw_MonthlyWorkforceKPI`

The Power BI semantic model continues to use the fact and dimension tables directly so the star schema is preserved.

---

## Repository Structure

```text
HR Analytics/
│
├── README.md
│
├── sql-scripts/
│   ├── 00_run_all.sql
│   ├── 01_create_database_and_tables.sql
│   ├── 02_populate_dimensions.sql
│   ├── 03_populate_employees.sql
│   ├── 04_populate_fact_employee_snapshot.sql
│   ├── 05_create_views.sql
│   ├── 06_validation_queries.sql
│   ├── 07_business_analysis_queries.sql
│   ├── 08_create_rls_security_mapping.sql
│   └── README.txt
│
├── docs/
│   ├── Consulting_Workforce_HR_Analytics_PowerBI_Project_Blueprint.md
│   └── data-model.md
│
├── assets/
│   └── report screenshots and supporting visuals
│
└── Power BI Project/
    ├── HR Analytics.pbip
    ├── HR Analytics.Report/
    └── HR Analytics.SemanticModel/
```

---

## Data Note

This project uses **synthetic workforce data** created for portfolio demonstration. The dataset is designed to represent a realistic consulting workforce scenario while keeping the project fully shareable in a public repository.

---

## Project Summary

This project demonstrates an end-to-end Power BI analytics workflow built around a realistic consulting workforce use case. The solution combines SQL validation, Power Query preparation, dimensional modeling, DAX development, report design, security, source control, and Power BI Service delivery in one project.

The final report provides a consolidated view of workforce size, utilization, billable capacity, bench exposure, hiring, attrition, promotions, engagement, performance, career levels, and geographic distribution. Dynamic Row-Level Security controls access by exact **Country × Service Line** combinations so the same semantic model can support different business audiences.

From a Power BI Analyst perspective, the project covers:

- working with a curated SQL Server dimensional model;
- validating fact grain, relationships, movement flags, and KPI results;
- preparing the reporting layer in Power Query with reusable parameters and incremental refresh logic;
- building and maintaining a star-schema semantic model;
- creating a DAX Date table and business-focused measures;
- separating point-in-time KPIs from period-based workforce measures;
- applying weighted utilization and appropriate business denominators;
- building interactive workforce and talent analysis pages;
- implementing and testing Dynamic RLS;
- maintaining PBIP/TMDL artifacts through Git and Azure Repos;
- publishing, refreshing, validating, and distributing the solution through Power BI Service.

The completed project shows how Power BI can be used not only for visualization, but as a governed analytics solution that connects data modeling, business logic, security, validation, and report delivery.
