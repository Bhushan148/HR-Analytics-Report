# Consulting Workforce & HR Analytics — Power BI Project Blueprint

## 1. Project Overview

**Project Name:** Consulting Workforce & HR Analytics  
**Industry:** Professional Services / Consulting / BPM  
**Reporting Tool:** Microsoft Power BI  
**Data Source:** SQL Server — `HRAnalytics`  
**Reporting Period:** October 2023 to September 2026  
**Fact Grain:** One employee × one monthly snapshot  
**Workforce Scale:** Mid-sized consulting organization with roughly 500–800 employees  
**Final Report Scope:** 2 Power BI report pages  
**Primary Audience:** HR Leadership, Workforce/Resource Management, Service Line Leaders, Practice Leaders

This project should be treated like a real internal consulting-company reporting assignment, not as a generic HR dashboard exercise.

The business operates across consulting, technology, risk, business operations, and internal corporate functions. Leadership needs one governed Power BI report to monitor workforce size, consulting utilization, bench exposure, hiring, promotions, engagement, performance, and attrition.

The project is intentionally designed so that the upstream data engineering work and the downstream BI/reporting work are clearly separated.

---

# 2. Business Scenario — How the Requirement Was Received

The HR and Workforce Management leadership team had workforce information available in multiple operational processes, but management reporting was fragmented.

The leadership team wanted a consolidated reporting solution that could answer questions such as:

- How many employees are currently active?
- How is workforce size changing over time?
- How is headcount distributed across Service Lines and Practices?
- What percentage of client-facing employees are billable?
- What is the current utilization rate?
- Which Service Lines have the highest bench exposure?
- Which career levels are most affected by bench?
- How many employees are being hired, promoted, transferred, and exited?
- Where is attrition concentrated?
- Is attrition higher for employees with greater bench exposure?
- Is engagement associated with attrition?
- Are stronger performers receiving more promotions?
- How does the career pyramid look from Analyst through Director?
- Which locations carry the largest workforce?
- Are workforce and utilization patterns materially different by country, location, Service Line, Practice, and Career Level?

The requirement was therefore not only an **HR headcount report**.

It was a combined:

**HR Analytics + Workforce Analytics + Resource Utilization Analytics + Consulting Operations Analytics** solution.

---

# 3. Stakeholders

## Primary stakeholders

### HR Leadership

Interested in:

- Current headcount
- Hiring
- Attrition
- Promotion
- Engagement
- Performance
- Tenure
- Workforce composition

### Workforce / Resource Management Team

Interested in:

- Billable employees
- Bench employees
- Utilization
- Bench days
- Project status
- Capacity by Service Line
- Capacity by Career Level
- Training during non-billable periods

### Service Line / Practice Leaders

Interested in:

- Workforce assigned to their Service Line
- Workforce assigned to each Practice
- Utilization
- Bench exposure
- Career-level mix
- Attrition
- Promotions
- Location mix

### HR Business Partners

Interested in:

- Attrition hotspots
- Engagement
- Performance
- Promotions
- Tenure
- Employee movement
- Workforce trends

---

# 4. Upstream Data Engineering Handoff

## Important project boundary

The Data Engineering team owned the upstream data pipelines and dimensional data preparation.

I did **not** build the raw source ingestion pipelines for this project.

The Data Engineering team delivered a curated dimensional model in SQL Server.

My responsibility started after receiving this curated model.

This is an important distinction when explaining the project in an interview.

### Data Engineering team responsibility

The upstream team was responsible for:

- Extracting data from operational HR/workforce systems
- Cleaning and standardizing source data
- Resolving employee identifiers
- Building dimensional tables
- Building the monthly employee snapshot fact table
- Maintaining surrogate keys
- Maintaining dimension/fact relationships
- Creating historical monthly snapshots
- Applying source-level data quality rules
- Loading SQL Server tables
- Maintaining primary keys and foreign keys
- Maintaining the approved report-security access mapping supplied by HR/IT
- Providing the curated model and security mapping for reporting

The underlying operational sources could include HR, resource-management, time/utilization, and learning processes, but the Power BI project consumes the **curated SQL Server dimensional layer**, not the raw source systems.

---

# 5. Data Model Received from Data Engineering

The SQL Server database is:

`HRAnalytics`

The dimensional model contains five primary business reporting tables plus one report-security mapping table.

```text
                     DimEmployee
                          |
                          |
DimDepartment -------- FactEmployeeSnapshot -------- DimJob
                          |
                          |
                     DimLocation


SecurityUserAccess
(disconnected security mapping table)
```

A Power BI Date table is created separately in DAX.

`SecurityUserAccess` is intentionally not part of the normal analytical star-schema relationships. It is used by Dynamic RLS to determine the exact Country × Service Line combinations the signed-in user is authorized to see.

---

# 6. Fact Table Grain

## FactEmployeeSnapshot

The grain is:

> One employee × one monthly snapshot

Examples:

```text
Employee 0125 | 2025-01-01
Employee 0125 | 2025-02-01
Employee 0125 | 2025-03-01
```

This allows Power BI to analyze historical changes rather than only the employee's current state.

For example:

```text
Jan 2025
Employee: E0125
Career Level: Consultant
Practice: Data & Analytics
Project Status: Billable

Apr 2025
Employee: E0125
Career Level: Senior Consultant
Practice: Data & Analytics
Project Status: Billable
PromotionFlag: 1

Aug 2025
Employee: E0125
Career Level: Senior Consultant
Practice: Data & Analytics
Project Status: Bench
BenchFlag: 1
```

This historical snapshot design is the core of the analytical model.

---

# 7. Tables Received

## 7.1 DimEmployee

Primary employee attributes:

- `EmployeeKey`
- `EmployeeID`
- `EmployeeName`
- `Gender`
- `EmploymentType`
- `HireType`
- `EducationLevel`
- `MaritalStatus`
- `WorkMode`
- `HireDate`
- `ExitDate`
- `EmployeeStatus`
- `ExitReason`
- `Age`
- `TotalExperienceYears`

Examples of categorical values:

**EmploymentType**

- Full-time
- Contract

**HireType**

- Campus Hire
- Experienced Hire
- Internal Transfer

**WorkMode**

- On-site
- Hybrid
- Remote

**EmployeeStatus**

- Active
- Resigned
- Terminated

Employee names and other identifying information are not required on the main management pages. Main pages remain aggregated.

---

## 7.2 DimDepartment

This dimension represents the consulting operating hierarchy.

Main columns:

- `DepartmentKey`
- `DepartmentID`
- `ServiceLine`
- `Practice`
- `DepartmentName`
- `DepartmentType`
- `IsClientFacing`

### Service Lines

- Consulting
- Technology
- Risk & Compliance
- Business Operations
- Internal Corporate Services

### Example Practices

**Consulting**

- Data & Analytics
- Business Transformation
- Strategy & Operations
- Digital Transformation

**Technology**

- Software Engineering
- Cloud & Infrastructure
- Cybersecurity
- ERP & Enterprise Apps

**Risk & Compliance**

- Risk Advisory
- Internal Audit
- Regulatory Compliance

**Business Operations**

- Finance Operations
- Customer Operations
- HR Operations
- Supply Chain Operations

**Internal Corporate Services**

- Talent & HR
- Corporate Finance
- Sales & Business Development
- Marketing & Communications

`IsClientFacing` distinguishes client-delivery practices from internal corporate support functions.

This becomes important when calculating consulting utilization and bench metrics.

---

## 7.3 DimLocation

Main columns:

- `LocationKey`
- `LocationID`
- `City`
- `StateName`
- `Region`
- `Country`
- `OfficeType`
- `CurrencyCode`

Locations include:

- Pune
- Mumbai
- Bengaluru
- Hyderabad
- New York
- Austin

Countries:

- India
- USA

This dimension enables geography-based workforce and utilization analysis.

---

## 7.4 DimJob

Main columns:

- `JobKey`
- `JobCode`
- `JobTitle`
- `CareerLevel`
- `JobFamily`
- `EmployeeCategory`
- `TypicalMinSalaryUSD`
- `TypicalMaxSalaryUSD`
- `TargetUtilizationPct`

### Career hierarchy

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

### EmployeeCategory

- Individual Contributor
- People Manager

### Job families include

- Analytics
- Business Transformation
- Strategy
- Technology
- Cloud
- Cybersecurity
- ERP
- Risk
- Operations
- Human Resources
- Finance
- Sales
- Marketing

`TargetUtilizationPct` provides a benchmark for comparing actual utilization with expected utilization.

---

## 7.5 FactEmployeeSnapshot

Main groups of fields are shown below.

### Keys

- `SnapshotKey`
- `EmployeeKey`
- `SnapshotDate`
- `DepartmentKey`
- `LocationKey`
- `JobKey`

### Compensation

- `AnnualBaseSalaryLocal`
- `CurrencyCode`
- `FXRateToUSD`
- `AnnualBaseSalaryUSD`
- `SalaryIncreasePct`
- `BonusAmountUSD`

Compensation fields are available in the model but are not the main focus of the first two-page report.

### Performance and engagement

- `PerformanceRating`
- `PerformanceCategory`
- `EngagementScore`
- `EngagementCategory`

### Tenure

- `TenureMonths`
- `TenureBand`

### Consulting operations

- `AvailableHours`
- `BillableHours`
- `UtilizationPct`
- `ProjectStatus`
- `BenchFlag`
- `BenchDays`
- `ProjectAssignmentCount`
- `TrainingHours`

### Workforce movement

- `HeadcountFlag`
- `NewHireFlag`
- `ExitFlag`
- `PromotionFlag`
- `TransferFlag`
- `SalaryChangeFlag`
- `MovementType`

### ProjectStatus categories

- Billable
- Bench
- Internal Project
- Training
- Leave

### MovementType categories

- No Change
- New Hire
- Promotion
- Transfer
- Exit

---

## 7.6 SecurityUserAccess

This table is part of the governed reporting handoff and is used only for Power BI Row-Level Security.

Security grain:

> One user × one Country × one Service Line allowed combination

Main columns:

- `SecurityAccessKey`
- `UserUPN`
- `Country`
- `ServiceLine`
- `IsActive`
- `CreatedAt`
- `UpdatedAt`

Current Country values:

- India
- USA

Current Service Line values:

- Consulting
- Technology
- Risk & Compliance
- Business Operations
- Internal Corporate Services

Example:

```text
UserUPN                              Country   ServiceLine
----------------------------------------------------------------------
india.resource.manager@company.com   India     Consulting
india.resource.manager@company.com   India     Technology

consulting.lead@company.com           India     Consulting
consulting.lead@company.com           USA       Consulting

portfolio.lead@company.com            India     Consulting
portfolio.lead@company.com            USA       Technology
```

The third example is important.

That user is authorized for:

```text
India + Consulting
USA   + Technology
```

The user must **not** automatically receive:

```text
India + Technology
USA   + Consulting
```

Therefore Country and Service Line permissions are maintained together at the exact combination grain rather than as two independent permission lists.

For a full-company user, all valid Country × Service Line combinations are loaded for that user. With the current model:

```text
2 Countries × 5 Service Lines = 10 valid combinations
```

The same Dynamic RLS role is used for restricted and full-company users.


# 8. SQL Views Available for Validation

The Data Engineering handoff also includes two supporting views.

## vw_EmployeeSnapshotEnriched

This joins the fact table with employee, department, location, and job dimensions.

It is useful for:

- SQL validation
- Business checks
- Ad-hoc analysis
- Reconciliation

It should **not replace the star schema inside Power BI**.

The Power BI model should import/use the separate dimensions and fact table so the model remains dimensional.

## vw_MonthlyWorkforceKPI

This provides monthly checks for:

- Headcount
- New hires
- Exits
- Promotions
- Transfers
- Billable employees
- Bench employees
- Average utilization
- Average engagement
- Average performance

This view is mainly useful for validating Power BI measures against SQL.

---

# 9. My Responsibility as the Power BI / Data Analyst

After receiving the dimensional model, my work starts.

The major responsibility areas are:

## Requirement Analysis

Understand what HR leadership, Resource Management, and Service Line leadership need to monitor.

Convert business questions into:

- KPIs
- Dimensions
- Filters
- Visual requirements
- Report interactions
- Business definitions

## Data Handoff Validation

Before building the report:

- Validate table row counts
- Validate snapshot date range
- Confirm fact grain
- Check duplicate Employee + SnapshotDate combinations
- Check snapshots are not created before HireDate
- Check snapshots are not created after ExitDate
- Validate NewHireFlag
- Validate ExitFlag
- Validate bench consistency
- Validate utilization ranges
- Review Service Line distribution
- Review Career Level distribution
- Compare monthly Power BI numbers with SQL validation views

## Power BI Data Connection

Connect Power BI Desktop to SQL Server.

Import:

- DimEmployee
- DimDepartment
- DimLocation
- DimJob
- FactEmployeeSnapshot
- SecurityUserAccess

Do not flatten all tables into a single Power Query table.

Preserve the star schema.

## Power Query

Because the upstream model is already curated, Power Query work should be relatively light.

Typical tasks:

- Confirm correct data types
- Rename technical fields only where needed for user readability
- Remove columns that are definitely not required by the report
- Keep surrogate keys for relationships
- Disable load for temporary/helper queries if any
- Check null behavior
- Validate date types
- Validate numeric types
- Validate currency fields
- Confirm `SecurityUserAccess[UserUPN]`, `Country`, `ServiceLine`, and `IsActive` are loaded correctly
- Keep `SecurityUserAccess` disconnected from the normal reporting relationships

Major business transformation should not be recreated in Power Query when it is already governed upstream.

---

# 10. Power BI Semantic Model

## Relationships

Recommended relationships:

```text
DimEmployee[EmployeeKey]
        1
        |
        *
FactEmployeeSnapshot[EmployeeKey]


DimDepartment[DepartmentKey]
        1
        |
        *
FactEmployeeSnapshot[DepartmentKey]


DimLocation[LocationKey]
        1
        |
        *
FactEmployeeSnapshot[LocationKey]


DimJob[JobKey]
        1
        |
        *
FactEmployeeSnapshot[JobKey]


DimDate[Date]
        1
        |
        *
FactEmployeeSnapshot[SnapshotDate]
```

Relationship direction:

**Single direction from dimension → fact**

Avoid unnecessary bidirectional relationships.

`SecurityUserAccess` remains disconnected from the analytical model:

```text
SecurityUserAccess
        X
        X   no normal relationship
        X
DimDepartment / DimLocation / FactEmployeeSnapshot
```

The table is referenced only by Dynamic RLS expressions.

---

# 11. Row-Level Security — Final Design

## Business Requirement

The same Power BI report is used by multiple HR, Resource Management, Service Line, and leadership users.

Different users must see different workforce populations without maintaining separate copies of the report.

The security requirement is based on:

```text
Country × Service Line
```

Examples:

- India HRBP → all Service Lines in India
- Global Consulting Leader → Consulting in India and USA
- India Technology Leader → Technology in India only
- India Resource Manager → Consulting + Technology in India
- Global Risk Leader → Risk & Compliance in both Countries
- Portfolio Leader → India + Consulting AND USA + Technology
- Global HR Head → all Country × Service Line combinations

## Final RLS Architecture

Use only **one Power BI role**:

```text
Dynamic_RLS
```

Use only **one SQL security table**:

```text
SecurityUserAccess

UserUPN
Country
ServiceLine
IsActive
```

Every approved user is assigned to `Dynamic_RLS` in Power BI Service.

The access table determines what that user can see.

Do not create separate roles such as:

```text
India_Access
USA_Access
Consulting_Access
Technology_Access
Global_Access
```

This avoids role proliferation and avoids relying on multiple independent RLS roles.

## Why Access Is Stored as a Combined Pair

Suppose a user is authorized for:

```text
India + Consulting
USA   + Technology
```

If Country and Service Line were evaluated independently, Power BI could interpret the user's allowed values as:

```text
Countries:
India
USA

Service Lines:
Consulting
Technology
```

That creates four possible combinations:

```text
India + Consulting      Allowed
India + Technology      Not Allowed
USA   + Consulting      Not Allowed
USA   + Technology      Allowed
```

The authorization requirement therefore has to be checked at the same grain as the permission:

> User × Country × Service Line

## Dynamic RLS Rule — DimLocation

Apply this filter to `DimLocation` inside the `Dynamic_RLS` role:

```DAX
VAR CurrentUser =
    USERPRINCIPALNAME()

RETURN
DimLocation[Country] IN
    SELECTCOLUMNS (
        FILTER (
            SecurityUserAccess,
            SecurityUserAccess[UserUPN] = CurrentUser
                && SecurityUserAccess[IsActive] = TRUE ()
        ),
        "AllowedCountry",
        SecurityUserAccess[Country]
    )
```

Purpose:

- Hides unauthorized Countries from the report
- Keeps Country and City slicers security-aware

## Dynamic RLS Rule — DimDepartment

Apply this filter to `DimDepartment` inside the same `Dynamic_RLS` role:

```DAX
VAR CurrentUser =
    USERPRINCIPALNAME()

RETURN
DimDepartment[ServiceLine] IN
    SELECTCOLUMNS (
        FILTER (
            SecurityUserAccess,
            SecurityUserAccess[UserUPN] = CurrentUser
                && SecurityUserAccess[IsActive] = TRUE ()
        ),
        "AllowedServiceLine",
        SecurityUserAccess[ServiceLine]
    )
```

Purpose:

- Hides unauthorized Service Lines
- Automatically restricts the Practice slicer because Practice belongs to DimDepartment

## Dynamic RLS Rule — FactEmployeeSnapshot

The fact-table rule enforces the **exact Country × Service Line combination**.

Apply:

```DAX
VAR CurrentUser =
    USERPRINCIPALNAME()

VAR CurrentCountry =
    RELATED ( DimLocation[Country] )

VAR CurrentServiceLine =
    RELATED ( DimDepartment[ServiceLine] )

RETURN
COUNTROWS (
    FILTER (
        SecurityUserAccess,
        SecurityUserAccess[UserUPN] = CurrentUser
            && SecurityUserAccess[Country] = CurrentCountry
            && SecurityUserAccess[ServiceLine] = CurrentServiceLine
            && SecurityUserAccess[IsActive] = TRUE ()
    )
) > 0
```

This is the rule that prevents unauthorized cross-combinations.

## Full-Company Access

A full-company user does not require a separate unrestricted role.

Instead, the security table contains all valid combinations for that user.

Current model:

```text
India + Consulting
India + Technology
India + Risk & Compliance
India + Business Operations
India + Internal Corporate Services

USA + Consulting
USA + Technology
USA + Risk & Compliance
USA + Business Operations
USA + Internal Corporate Services
```

Total:

```text
10 access rows
```

The user is still assigned only to:

```text
Dynamic_RLS
```

## Example Access Scenarios

### India HRBP

```text
Country:
India

Service Lines:
Consulting
Technology
Risk & Compliance
Business Operations
Internal Corporate Services
```

Result:

> All Service Lines in India, no USA data.

### Global Consulting Leader

```text
India + Consulting
USA   + Consulting
```

Result:

> Consulting workforce across both countries.

### India Technology Leader

```text
India + Technology
```

Result:

> Technology workforce in India only.

### India Resource Manager

```text
India + Consulting
India + Technology
```

Result:

> Consulting and Technology workforce in India only.

### Portfolio Leader

```text
India + Consulting
USA   + Technology
```

Result:

> Exactly those two combinations, without cross-combination access.

### Global HR Head

```text
All 10 combinations
```

Result:

> Full company visibility while still using `Dynamic_RLS`.

## Power BI Desktop Testing

Use:

**Modeling → Manage roles**

Create:

`Dynamic_RLS`

Then use:

**Modeling → View as → Other user**

Test representative users such as:

- India HRBP
- Consulting Leader
- India Technology Leader
- Portfolio Leader
- Global HR Head

For each persona confirm:

- Expected Country values
- Expected Service Line values
- Expected Practice values
- Expected headcount
- No unauthorized combinations appear

## Power BI Service

After publishing:

1. Open the semantic model security settings.
2. Add approved report consumers to `Dynamic_RLS`.
3. Maintain their exact permissions in `SecurityUserAccess`.
4. Keep restricted business consumers as Viewer/App consumers.
5. Do not give restricted business users edit-level workspace roles if RLS is expected to restrict them.
6. Re-test representative users in Power BI Service before production sign-off.

## RLS Ownership

In a production scenario:

### HR / Business Owner

Approves who should have access to which workforce scope.

### IT / Data Engineering

Maintains or loads the approved `SecurityUserAccess` mapping into SQL Server.

### Power BI / Data Analyst

Responsible for:

- Implementing `Dynamic_RLS`
- Applying the three RLS expressions
- Testing access scenarios
- Reconciling secured headcount
- Validating slicer behavior
- Testing in Power BI Service
- Documenting the security design
- Supporting UAT and sign-off

This keeps authorization ownership separate from report development.

---

# 12. Date Table — Created in Power BI

No SQL Date dimension is required for this project.

Create it using DAX.

```DAX
DimDate =
VAR MinDate =
    MIN ( FactEmployeeSnapshot[SnapshotDate] )
VAR MaxDate =
    MAX ( FactEmployeeSnapshot[SnapshotDate] )
RETURN
ADDCOLUMNS (
    CALENDAR ( MinDate, MaxDate ),
    "Year", YEAR ( [Date] ),
    "Month Number", MONTH ( [Date] ),
    "Month", FORMAT ( [Date], "MMM" ),
    "Month Name", FORMAT ( [Date], "MMMM" ),
    "Year Month", FORMAT ( [Date], "YYYY-MMM" ),
    "Year Month Sort", YEAR ( [Date] ) * 100 + MONTH ( [Date] ),
    "Quarter", "Q" & FORMAT ( [Date], "Q" )
)
```

Because the fact table is monthly, report visuals should normally use the month-level reporting grain.

Sort:

`Year Month` by `Year Month Sort`.

Mark `DimDate` as the Date table.

---

# 13. Business Metric Definitions

Metric definitions should be agreed with stakeholders before final sign-off.

## Headcount

Number of employee snapshot records in a month.

Because the fact grain is one employee per month:

```DAX
Headcount =
SUM ( FactEmployeeSnapshot[HeadcountFlag] )
```

---

## Latest Visible Snapshot Date

This allows KPI cards to show the latest month inside the selected reporting period.

```DAX
Latest Visible Snapshot Date =
MAX ( FactEmployeeSnapshot[SnapshotDate] )
```

---

## Current Headcount

```DAX
Current Headcount =
VAR SnapshotDate =
    [Latest Visible Snapshot Date]
RETURN
CALCULATE (
    [Headcount],
    FactEmployeeSnapshot[SnapshotDate] = SnapshotDate
)
```

---

## Billable Employees

```DAX
Billable Employees =
VAR SnapshotDate =
    [Latest Visible Snapshot Date]
RETURN
CALCULATE (
    DISTINCTCOUNT ( FactEmployeeSnapshot[EmployeeKey] ),
    FactEmployeeSnapshot[SnapshotDate] = SnapshotDate,
    FactEmployeeSnapshot[ProjectStatus] = "Billable"
)
```

---

## Current Utilization %

Use a weighted calculation.

Do **not** simply average employee utilization percentages.

```DAX
Current Utilization % =
VAR SnapshotDate =
    [Latest Visible Snapshot Date]
VAR BillableHours =
    CALCULATE (
        SUM ( FactEmployeeSnapshot[BillableHours] ),
        FactEmployeeSnapshot[SnapshotDate] = SnapshotDate,
        DimDepartment[IsClientFacing] = TRUE ()
    )
VAR AvailableHours =
    CALCULATE (
        SUM ( FactEmployeeSnapshot[AvailableHours] ),
        FactEmployeeSnapshot[SnapshotDate] = SnapshotDate,
        DimDepartment[IsClientFacing] = TRUE ()
    )
RETURN
DIVIDE ( BillableHours, AvailableHours )
```

---

## Bench Employees

```DAX
Bench Employees =
VAR SnapshotDate =
    [Latest Visible Snapshot Date]
RETURN
CALCULATE (
    SUM ( FactEmployeeSnapshot[BenchFlag] ),
    FactEmployeeSnapshot[SnapshotDate] = SnapshotDate,
    DimDepartment[IsClientFacing] = TRUE ()
)
```

---

## Bench Rate %

```DAX
Bench Rate % =
DIVIDE (
    [Bench Employees],
    [Current Client-Facing Headcount]
)
```

---

## New Hires

```DAX
New Hires =
SUM ( FactEmployeeSnapshot[NewHireFlag] )
```

---

## Exits

```DAX
Exits =
SUM ( FactEmployeeSnapshot[ExitFlag] )
```

---

## Promotions

```DAX
Promotions =
SUM ( FactEmployeeSnapshot[PromotionFlag] )
```

---

## Transfers

```DAX
Transfers =
SUM ( FactEmployeeSnapshot[TransferFlag] )
```

---

## Average Monthly Headcount

```DAX
Average Monthly Headcount =
AVERAGEX (
    VALUES ( DimDate[Year Month] ),
    [Headcount]
)
```

---

## Attrition Rate %

For this project, the visible metric should be clearly labelled as the **selected-period attrition rate**.

```DAX
Attrition Rate % =
DIVIDE (
    [Exits],
    [Average Monthly Headcount]
)
```

The exact business definition should be confirmed with HR because organizations may use different monthly, annualized, rolling-12-month, or YTD definitions.

---

## Promotion Rate %

```DAX
Promotion Rate % =
DIVIDE (
    [Promotions],
    [Average Monthly Headcount]
)
```

---

## Average Performance

```DAX
Average Performance =
AVERAGE ( FactEmployeeSnapshot[PerformanceRating] )
```

---

## Average Engagement

```DAX
Average Engagement =
AVERAGE ( FactEmployeeSnapshot[EngagementScore] )
```

---

## Average Bench Days

```DAX
Average Bench Days =
CALCULATE (
    AVERAGE ( FactEmployeeSnapshot[BenchDays] ),
    FactEmployeeSnapshot[BenchFlag] = 1
)
```

---

## Total Training Hours

```DAX
Training Hours =
SUM ( FactEmployeeSnapshot[TrainingHours] )
```

---

# 14. Report UX Strategy

The final report contains only **two visible report pages**.

The goal is to avoid creating a large HR report.

The report should feel like an executive operational dashboard used by HR and consulting workforce leadership.

## Page structure

Recommended canvas:

**16:9 widescreen**

Example:

`1440 × 810`

### Left side

Persistent slicer/navigation panel.

### Right side

Main analytical canvas.

General structure:

```text
┌───────────────┬─────────────────────────────────────────────┐
│               │ Report Title / Context / Latest Period      │
│               ├─────────────────────────────────────────────┤
│               │ Main KPI Cards                              │
│   SIDE        ├─────────────────────────────────────────────┤
│   FILTER      │ Secondary KPI Strip                         │
│   PANEL       ├─────────────────────────────────────────────┤
│               │                                             │
│               │ Main Analytical Visuals                     │
│               │                                             │
│               │                                             │
└───────────────┴─────────────────────────────────────────────┘
```

---

# 15. Side Slicer Panel

The slicer panel should remain visually consistent across both pages.

Recommended width:

**210–230 px**

## Common slicers

### Reporting Period

`DimDate[Year Month]`

Recommended behavior:

- Between/range selection for analysis period
- Default report view can open on the latest 12 months
- KPI measures that represent current state use the latest visible snapshot

### Country

`DimLocation[Country]`

### City

`DimLocation[City]`

### Service Line

`DimDepartment[ServiceLine]`

### Practice

`DimDepartment[Practice]`

### Career Level

`DimJob[CareerLevel]`

These six are the core slicers.

## Optional contextual slicers

Page 1:

- Project Status
- Work Mode

Page 2:

- Tenure Band
- Performance Category
- Engagement Category
- Gender

Do not overload the permanent panel with every available field.

Use only filters that materially help decision-making.

## Slicer UX

Include:

- Search where helpful
- Dropdown slicers for long categories
- Clear filter icon
- A visible **Reset Filters** button using a bookmark
- Synced common slicers across both report pages

---

# 16. Page 1 — Workforce & Utilization Overview

## Business purpose

This page answers:

> What does the consulting workforce look like today, how is it distributed, and how effectively is client-facing capacity being utilized?

This is the primary operational workforce page.

---

## Page 1 Header

Title:

**Workforce & Utilization Overview**

Subtitle:

**Consulting workforce capacity, deployment and utilization**

Display:

- Latest visible snapshot month
- Data refresh date if available
- Selected Service Line / Country context where useful

---

# 17. Page 1 — Main KPI Row

Use five equal KPI cards.

## KPI 1 — Current Headcount

**Measure:** Current Headcount

Supporting context:

- vs prior month
- directional indicator

Example:

```text
634
Current Headcount
▲ 1.4% vs Prior Month
```

---

## KPI 2 — Billable Employees

**Measure:** Billable Employees

Supporting context:

- Billable share of client-facing workforce

Example:

```text
435
Billable Employees
68.6% of Workforce
```

---

## KPI 3 — Utilization %

**Measure:** Current Utilization %

Supporting context:

- actual utilization
- target utilization comparison

Example:

```text
81.7%
Utilization
+1.8 pp vs Target
```

---

## KPI 4 — Bench Rate %

**Measure:** Bench Rate %

Supporting context:

- Bench Employees
- direction vs prior month

Example:

```text
9.2%
Bench Rate
56 Employees
```

---

## KPI 5 — Average Engagement

**Measure:** Average Engagement

Supporting context:

- engagement category or prior-period movement

Example:

```text
77.8
Avg Engagement
▲ 1.3 vs Prior Period
```

---

# 18. Page 1 — Secondary KPI Strip

Use smaller cards directly below the main KPI row.

Recommended secondary KPIs:

### New Hires

Selected-period hires.

### Exits

Selected-period exits.

### Promotions

Selected-period promotions.

### Transfers

Selected-period transfers.

### Average Bench Days

Bench employees only.

### Training Hours

Selected-period training hours.

These metrics support workforce movement without competing visually with the main operational KPIs.

---

# 19. Page 1 — Visual 1

## Workforce Trend

**Visual:** Line and clustered column chart

### X-axis

`DimDate[Year Month]`

### Columns

- New Hires
- Exits

### Line

- Headcount

### Purpose

Shows whether workforce growth is being driven by hiring, reduced exits, or both.

Business question:

> Is the consulting workforce expanding, stable, or contracting?

---

# 20. Page 1 — Visual 2

## Headcount by Service Line

**Visual:** Horizontal bar chart

### Axis

`DimDepartment[ServiceLine]`

### Value

Current Headcount

### Sort

Descending by headcount.

### Tooltip

- Headcount
- Billable Employees
- Utilization %
- Bench Employees
- Average Engagement

Business question:

> Where is the workforce concentrated?

---

# 21. Page 1 — Visual 3

## Actual vs Target Utilization by Service Line

**Visual:** Clustered bar chart

### Axis

`ServiceLine`

### Values

- Actual Utilization %
- Target Utilization %

Filter:

`IsClientFacing = TRUE`

Business question:

> Which client-facing Service Lines are under or above their expected utilization level?

This is more meaningful than showing utilization alone.

---

# 22. Page 1 — Visual 4

## Project Status Mix

**Visual:** 100% stacked bar chart

Categories:

- Billable
- Bench
- Internal Project
- Training
- Leave

Value:

Employee count.

Recommended breakdown:

`ServiceLine`

Business question:

> How is available workforce capacity currently deployed?

This chart makes consulting operating status immediately visible.

---

# 23. Page 1 — Visual 5

## Career Pyramid

**Visual:** Horizontal bar chart

### Axis

Career Level

Custom sort:

1. Analyst
2. Consultant
3. Senior Consultant
4. Manager
5. Senior Manager
6. Director

### Value

Current Headcount

Business question:

> Does the organization have a healthy consulting career pyramid?

The expected profile should normally be wider at Analyst/Consultant levels and narrower at senior leadership levels.

---

# 24. Page 1 — Visual 6

## Workforce by Location

**Visual:** Clustered bar chart

### Axis

City

### Primary value

Current Headcount

### Tooltip

- Utilization %
- Bench Employees
- New Hires
- Exits

Business question:

> Which delivery locations hold the largest workforce, and what is their operating profile?

A map is not necessary for this project because precise comparison between locations is more useful than geographic decoration.

---

# 25. Page 1 — Recommended Layout

```text
┌───────────────┬──────────────────────────────────────────────────────────────┐
│               │ Workforce & Utilization Overview                           │
│               ├──────────┬──────────┬──────────┬──────────┬───────────────┤
│               │Headcount │Billable  │Util. %   │Bench %   │Engagement     │
│               ├──────────┴──────────┴──────────┴──────────┴───────────────┤
│               │ Hires | Exits | Promotions | Transfers | Bench Days | TH  │
│   SLICER      ├───────────────────────────────┬──────────────────────────────┤
│   PANEL       │ Workforce Trend               │ Headcount by Service Line   │
│               │                               │                              │
│               ├───────────────────────────────┼──────────────────────────────┤
│               │ Actual vs Target Utilization  │ Project Status Mix          │
│               │                               │                              │
│               ├───────────────────────────────┼──────────────────────────────┤
│               │ Career Pyramid                │ Workforce by Location       │
│               │                               │                              │
└───────────────┴───────────────────────────────┴──────────────────────────────┘
```

---

# 26. Page 2 — Talent & Attrition Insights

## Business purpose

This page answers:

> Where are we losing employees, what workforce conditions are associated with those exits, and are talent outcomes aligned with performance and engagement?

This page is more diagnostic than Page 1.

---

# 27. Page 2 Header

Title:

**Talent & Attrition Insights**

Subtitle:

**Employee movement, retention, engagement and promotion analysis**

The same common slicer panel remains on the left.

---

# 28. Page 2 — Main KPI Row

## KPI 1 — Attrition Rate %

Selected-period attrition rate.

Supporting context:

- vs previous comparable period

---

## KPI 2 — Total Exits

Supporting context:

- number of exit events

---

## KPI 3 — Promotion Rate %

Supporting context:

- total promotions

---

## KPI 4 — Average Performance

Scale:

1–5

Supporting context:

- high-performance share if required

---

## KPI 5 — Average Engagement

Scale:

0–100

Supporting context:

- low-engagement employee share if required

---

# 29. Page 2 — Secondary KPI Strip

Recommended:

- New Hires
- Promotions
- Average Exit Tenure
- Low Engagement Employees
- High Performers
- Training Hours

These metrics provide context around retention and talent development.

---

# 30. Page 2 — Visual 1

## Attrition Trend

**Visual:** Line and clustered column chart

### X-axis

Year Month

### Columns

Exits

### Line

Attrition Rate %

Business question:

> Is attrition increasing, improving, or showing seasonal spikes?

---

# 31. Page 2 — Visual 2

## Attrition by Service Line

**Visual:** Horizontal bar chart

### Axis

Service Line

### Values

- Attrition Rate %
- Exits in tooltip

Business question:

> Which parts of the consulting business have the greatest retention risk?

Do not rank only by raw exits because larger Service Lines naturally produce more exits.

Rate and volume should both be visible.

---

# 32. Page 2 — Visual 3

## Attrition by Career Level

**Visual:** Bar chart

### Axis

Career Level

### Value

Attrition Rate %

### Tooltip

- Headcount
- Exits
- Average Engagement
- Average Bench Days

Business question:

> At which stage of the consulting career pyramid is attrition most concentrated?

---

# 33. Page 2 — Visual 4

## Attrition by Tenure Band

**Visual:** Horizontal bar chart

### Axis

Tenure Band

Suggested order:

1. < 1 Year
2. 1–2 Years
3. 2–5 Years
4. 5–10 Years
5. 10+ Years

### Value

Attrition Rate %

Business question:

> At what point in employee tenure is retention weakest?

---

# 34. Page 2 — Visual 5

## Bench Exposure vs Attrition

This is one of the most consulting-specific visuals in the report.

### Recommended analytical bands

- No Bench
- 1–20 Days
- 21–45 Days
- 46+ Days

### Value

Exit %

Business question:

> Are employees with greater bench exposure more likely to exit?

### Important implementation note

The supplied SQL business-analysis query calculates **total employee bench exposure across the observation period**.

For the Power BI visual, do not casually use a simple monthly `BenchDays` average and call it employee bench exposure.

Either:

1. Build the measure carefully at Employee level in DAX, or
2. Ask Data Engineering for an approved employee-level bench-exposure reporting view if this becomes a production requirement.

This is a good example of when the BI analyst should not force an incorrect calculation simply because a field exists.

---

# 35. Page 2 — Visual 6

## Performance vs Promotion

**Visual:** Bar chart

### Axis

Performance Category

Order:

1. Needs Significant Improvement
2. Needs Improvement
3. Meets Expectations
4. Exceeds Expectations
5. Outstanding

### Value

Promotion Rate %

### Tooltip

- Promotion Count
- Employee Count
- Average Engagement

Business question:

> Are promotion outcomes aligned with employee performance?

---

# 36. Page 2 — Optional Swap Visual

If the page becomes visually crowded, use one of these instead of a sixth chart.

## Engagement vs Attrition

Axis:

- Low
- Moderate
- High

Value:

Attrition Rate %

Business question:

> Is lower engagement associated with higher employee exits?

This can replace either Attrition by Career Level or Performance vs Promotion depending on stakeholder priority.

---

# 37. Page 2 — Recommended Layout

```text
┌───────────────┬──────────────────────────────────────────────────────────────┐
│               │ Talent & Attrition Insights                                │
│               ├──────────┬──────────┬──────────┬──────────┬───────────────┤
│               │Attrition │Exits     │Promotion │Performance│Engagement     │
│               ├──────────┴──────────┴──────────┴──────────┴───────────────┤
│               │ Hires | Promotions | Exit Tenure | Low Eng. | High Perf.  │
│   SLICER      ├───────────────────────────────┬──────────────────────────────┤
│   PANEL       │ Attrition Trend               │ Attrition by Service Line   │
│               │                               │                              │
│               ├───────────────────────────────┼──────────────────────────────┤
│               │ Attrition by Career Level     │ Attrition by Tenure Band    │
│               │                               │                              │
│               ├───────────────────────────────┼──────────────────────────────┤
│               │ Bench Exposure vs Attrition   │ Performance vs Promotion    │
│               │                               │                              │
└───────────────┴───────────────────────────────┴──────────────────────────────┘
```

---

# 38. Visual Interaction Rules

The report should behave consistently.

## Slicers

Common slicers filter both pages.

## Chart cross-filtering

Selecting a:

- Service Line
- Practice
- Career Level
- City
- Project Status

should filter relevant visuals on the same page.

## Avoid misleading interactions

Some KPI cards should remain focused on the correct population.

For example:

- Utilization should focus on client-facing workforce.
- Bench Rate should focus on client-facing workforce.
- Internal corporate functions should not reduce client utilization simply because their target utilization is zero.

## Reset button

Create a bookmark:

**Reset Filters**

It restores:

- all common slicers
- default date window
- default page state

---

# 39. Report Formatting Principles

The dashboard should look like an internal consulting management report, not a decorative portfolio poster.

Use:

- Clear hierarchy
- Strong whitespace
- Consistent card sizes
- Minimal borders
- Limited visual types
- Consistent number formatting
- Consistent KPI terminology
- Short titles
- Meaningful subtitles
- No unnecessary icons
- No excessive colors

Use color primarily to communicate:

- Normal
- Positive
- Warning
- Risk

Avoid assigning a different unrelated color to every category unless necessary.

---

# 40. Number Formatting

Recommended:

### Headcount

`634`

### Utilization

`81.7%`

### Bench Rate

`9.2%`

### Engagement

`77.8`

### Performance

`3.6 / 5`

### Training Hours

`1.8K hrs`

### Salary

If used:

`$42.5K`

Avoid excessive decimal places.

---

# 41. Tooltip Strategy

Tooltips should add useful operational context without creating another visible report page.

For Service Line charts, tooltip content can include:

- Current Headcount
- Utilization %
- Billable Employees
- Bench Employees
- Average Bench Days
- Engagement
- Exits

For Career Level charts:

- Headcount
- Attrition Rate
- Promotion Rate
- Average Performance
- Average Engagement

Keep tooltips compact.

---

# 42. Data Privacy

This dataset contains EmployeeName and employee-level attributes.

The management dashboard should remain aggregated.

Do not expose employee names in the two main report pages.

For a real production implementation:

- Workspace access should be restricted
- HR-sensitive fields should be governed
- Employee-level detail should only be exposed when explicitly required
- Row-level security should use the approved `SecurityUserAccess` mapping
- Security should be tested at the exact Country × Service Line combination grain
- Access changes should be governed through the upstream security mapping rather than hardcoded into visuals

The model now includes the governed `SecurityUserAccess` mapping required for Dynamic RLS.

---

# 43. Validation Before Report Sign-Off

Before sharing the report, validate:

## Data model

- Every dimension has unique keys
- Fact EmployeeKey matches DimEmployee
- Fact DepartmentKey matches DimDepartment
- Fact LocationKey matches DimLocation
- Fact JobKey matches DimJob
- Date relationship is active
- No many-to-many relationships were accidentally created
- `SecurityUserAccess` remains disconnected
- Only one Power BI RLS role exists: `Dynamic_RLS`

## Fact grain

Check:

`EmployeeKey + SnapshotDate`

must be unique.

## Snapshot dates

Confirm:

- No snapshot before HireDate
- No snapshot after ExitDate

## Flags

Check:

- NewHireFlag aligns with hire month
- ExitFlag aligns with exit month
- BenchFlag aligns with ProjectStatus = Bench
- PromotionFlag appears only in actual promotion months
- TransferFlag appears only in actual movement months

## Utilization

Check:

- Billable Hours ≤ reasonable Available Hours threshold
- Utilization is within expected range
- Internal Corporate Services are excluded where appropriate from utilization analysis

## RLS validation

Test representative security personas:

- India HRBP
- Global Consulting Leader
- India Technology Leader
- Portfolio Leader
- Global HR Head

For each user validate:

- Allowed Country values
- Allowed Service Line values
- Allowed Practices
- Secured headcount
- No unauthorized Country × Service Line combination appears
- Full-company user receives all expected combinations

Pay special attention to the portfolio scenario:

```text
Allowed:
India + Consulting
USA   + Technology

Must not appear:
India + Technology
USA   + Consulting
```

## Power BI reconciliation

Compare Power BI output with SQL:

- Monthly headcount
- New hires
- Exits
- Promotions
- Transfers
- Billable employees
- Bench employees
- Utilization
- Engagement
- Performance

Use `vw_MonthlyWorkforceKPI` as a reconciliation source.

---

# 44. UAT — User Acceptance Testing

Before final publishing, review the report with stakeholders.

Example UAT questions:

### HR Leadership

- Does headcount match the monthly HR close number?
- Is the attrition definition correct?
- Are promotions counted according to HR policy?
- Are engagement categories understood correctly?

### Resource Management

- Is utilization calculated correctly?
- Are internal employees excluded from client-utilization metrics?
- Is bench logic correct?
- Are Project Status categories meaningful?

### Service Line Leaders

- Does Service Line / Practice hierarchy match the operating structure?
- Can they filter their own area easily?
- Are utilization and bench numbers understandable?
- Do career-level distributions look correct?

### Security / RLS

- Does each test user see only the approved Country × Service Line combinations?
- Are Country, Service Line, and Practice slicers automatically restricted?
- Does the Portfolio Leader scenario avoid unauthorized cross-combinations?
- Does the Global HR user see the full company?
- Are secured KPI totals reconciled with SQL expectations?

Document any definition or access changes before production deployment.

---

# 45. Power BI Service Deployment

After UAT:

1. Publish the report and semantic model to the appropriate Power BI workspace.
2. Configure SQL Server credentials.
3. Configure an enterprise gateway if the SQL Server environment requires it.
4. Set the refresh schedule to align with the monthly workforce snapshot load.
5. Validate refresh success.
6. Configure the `Dynamic_RLS` role on the semantic model.
7. Add approved consumers to the `Dynamic_RLS` role.
8. Validate representative RLS personas in Power BI Service.
9. Validate report and workspace permissions.
10. Publish through a Power BI App if that is the organization's distribution approach.
11. Share only with approved HR, Resource Management, and business leadership audiences.

Because the fact table is monthly snapshot data, the refresh cadence should align with the upstream monthly close/load rather than refreshing constantly without new source data.

---

# 46. Final Deliverables Shared with Stakeholders

The completed project handoff includes:

## Power BI Report

Two visible pages:

1. Workforce & Utilization Overview
2. Talent & Attrition Insights

## Power BI Semantic Model

Contains:

- Four SQL dimensions
- One SQL fact
- One SQL security mapping table
- One DAX Date dimension
- Star-schema relationships
- One `Dynamic_RLS` role
- Country × Service Line security logic
- DAX measures
- Formatting
- Hidden technical columns

## Metric Definition Document

Contains definitions for:

- Headcount
- Billable Employees
- Utilization
- Bench
- Attrition
- Promotions
- Engagement
- Performance

## Validation Notes

Contains:

- SQL reconciliation results
- Data-quality checks
- RLS persona test results
- Known caveats
- UAT outcomes

---

# 47. Project Scope — What Was Not Included

To keep the project focused, the first release does not include:

- Client revenue
- Billing rates
- Project profitability
- Project margin
- Contract values
- Detailed project P&L
- Recruitment funnel
- Applicant tracking
- Daily attendance
- Leave management
- Payroll processing
- Detailed compensation dashboard
- Individual employee performance detail
- Manager/direct-report hierarchy RLS
- Object-level security (OLS)

These can become future reports or model extensions.

---

# 48. Why the Report Is Limited to Two Pages

The source model contains many fields, but a good Power BI report should not display every available field.

The final two-page structure is intentional.

## Page 1

Answers:

> What is happening with our workforce and consulting capacity?

## Page 2

Answers:

> Where are the main talent and retention risks?

That creates a clear business story instead of a large report with many disconnected pages.

---

# 49. End-to-End Project Flow

The complete project flow is:

```text
Business Requirement
        ↓
Stakeholder Discussion
        ↓
Metric Definition
        ↓
Data Engineering Dimensional Model Handoff
        ↓
SQL Data Validation
        ↓
Power BI Connection
        ↓
Power Query Data-Type / Quality Checks
        ↓
Star Schema Relationship Setup
        ↓
DAX Date Table
        ↓
DAX Measure Development
        ↓
Dynamic RLS Configuration
        ↓
Country × Service Line Security Testing
        ↓
Measure Reconciliation with SQL
        ↓
Report Wireframe
        ↓
Page 1 Build
        ↓
Page 2 Build
        ↓
Visual Interaction Setup
        ↓
Formatting
        ↓
Performance Check
        ↓
Business QA
        ↓
RLS Persona QA
        ↓
UAT
        ↓
Power BI Service Publish
        ↓
Refresh Configuration
        ↓
Dynamic_RLS Role Assignment
        ↓
Power BI Service Security Validation
        ↓
Permission Validation
        ↓
Final Stakeholder Handover
```

---

# 50. How to Explain This Project in an Interview

A natural explanation would be:

> I worked on a consulting workforce analytics project where the main requirement was to give HR leadership, Resource Management, and Service Line leaders a consolidated view of workforce capacity and talent health.
>
> The upstream Data Engineering team provided a curated SQL Server dimensional model. It had employee, department, location, and job dimensions with a monthly employee snapshot fact table. The snapshot grain was one employee per month, which allowed us to analyze historical changes in utilization, bench status, career level, engagement, performance, promotions, transfers, and exits.
>
> My responsibility started from validating that reporting layer. I checked the fact grain, key relationships, snapshot periods, workforce movement flags, and utilization logic, and reconciled the results with SQL validation queries.
>
> In Power BI I preserved the star schema, created the Date table, built the DAX measures, and designed two report pages. The first page focused on workforce and consulting operations, so it covered headcount, billable employees, utilization, bench, Service Line mix, career pyramid, and locations. The second page focused on talent and attrition, including exits, attrition by Service Line and career level, tenure, engagement, performance, promotion patterns, and bench exposure.
>
> I also implemented Dynamic RLS using a governed security table at the Country × Service Line combination level. All consumers used one `Dynamic_RLS` role, and `USERPRINCIPALNAME()` was used to identify the signed-in user. This supported scenarios such as India-only HR access, global Service Line leadership, mixed Country/Service Line portfolios, and full-company HR access without maintaining separate report copies or many static roles.
>
> After the build, I validated Power BI metrics against SQL, tested representative RLS personas, completed UAT with the business users, published the report to Power BI Service, configured refresh based on the monthly workforce snapshot, assigned approved consumers to the security role, and shared the final report with the approved stakeholder group.

This explanation accurately positions the work as a **Power BI / analytics responsibility** without claiming ownership of upstream Data Engineering pipelines.

---

# 51. Key Learning Outcomes from This Project

By completing this project, the main skills demonstrated are:

### SQL / Data Understanding

- Dimensional model understanding
- Fact grain understanding
- Data validation
- Reconciliation
- Business-query interpretation

### Data Modeling

- Star schema
- Surrogate keys
- One-to-many relationships
- Historical snapshot fact
- Date dimension
- Filter direction

### DAX

- Current-state measures
- Period measures
- Weighted utilization
- Attrition
- Headcount
- Hiring
- Exits
- Promotions
- Bench analysis
- Performance
- Engagement

### Power BI Security

- Dynamic RLS
- `USERPRINCIPALNAME()`
- Security mapping tables
- Exact Country × Service Line authorization
- RLS persona testing
- Power BI Service role assignment
- Viewer/App consumer security

### Power BI Report Development

- KPI hierarchy
- Side slicer panel
- Synced slicers
- Cross-filtering
- Bookmarks
- Reset filters
- Comparative charts
- Workforce trends
- Consulting operations analysis
- Talent diagnostics

### Business Understanding

- Service Lines
- Practices
- Career pyramid
- Billable workforce
- Utilization
- Bench
- Project status
- Resource capacity
- Promotions
- Attrition
- Engagement
- Consulting workforce operations

### Delivery

- Requirement gathering
- Stakeholder alignment
- Data validation
- UAT
- Power BI Service publishing
- Refresh configuration
- Dynamic RLS deployment
- Security validation
- Permissions
- Final business handover

---

# 52. Final Report Summary

The final report should feel like an internal workforce-management product used by a consulting company.

It is **not** intended to be a generic HR dashboard.

The final story is:

```text
PAGE 1
Workforce & Utilization Overview

How large is our workforce?
Where are people located?
Where are they deployed?
How many are billable?
What is utilization?
How much bench capacity exists?
How does our consulting career pyramid look?


PAGE 2
Talent & Attrition Insights

Where are employees leaving?
Which Service Lines and Career Levels have retention pressure?
At what tenure stage are exits occurring?
Does bench exposure appear related to attrition?
How are engagement and performance behaving?
Are promotions aligned with stronger performance?
```

The same two-page report is secured using **one Dynamic RLS role** with exact **Country × Service Line** authorization, allowing different HR, Resource Management, Service Line, and global leadership users to consume the same semantic model safely.

That gives the project a realistic consulting-sector business narrative from **data-engineering handoff through secured final Power BI delivery**.
