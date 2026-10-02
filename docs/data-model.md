# Data Model — HRAnalytics

**Database:** `HRAnalytics` (local MS SQL Server, Windows Authentication)
**Pattern:** Star Schema with a monthly snapshot fact table

## Schema Diagram

```
                DimDate (12 rows, Jan-Dec 2026)
                       │
DimDepartment (3) ─────┼───── DimLocation (2: India, USA)
                       │
                       ▼
              FactEmployeeSnapshot (342 rows)
                       ▲
                       │
                DimEmployee (30 rows)
```

## Grain

**1 row per employee per month, for every month they were employed.**
This is a *snapshot fact table* — the standard pattern for headcount,
attrition, and salary-trend reporting. It answers "who was employed,
in which department/location, at what salary, as of this month-end?"

## Tables

### DimDate
| Column | Type | Notes |
|---|---|---|
| DateKey | INT (PK) | yyyymm, e.g. 202601 |
| MonthStartDate | DATE | |
| Year, MonthNumber, MonthName, MonthYear | | |

### DimDepartment
3 rows: Sales, Engineering, Human Resources.

### DimLocation
2 rows: Mumbai (Region = India), New York (Region = USA).
**`Region` is the field used for RLS (Stage 12).**

### DimEmployee
30 employees with categorical fields for filtering/segmentation practice:
`Gender`, `DesignationLevel` (Junior/Senior/Lead), `EmploymentType`
(Full-time/Contract), plus `JoiningDate`/`ExitDate`/`IsActive`.

4 employees exit during 2026 (March, June, September, December) — gives
the fact table real attrition to report on.

### FactEmployeeSnapshot
| Column | Notes |
|---|---|
| EmployeeKey, DateKey | Composite PK |
| DepartmentKey, LocationKey | Snapshot at that point in time |
| Salary | Flat per employee (no raises modeled) — keeps validation simple |
| PerformanceRating | Only set in December (1-5) |
| AttritionFlag | 1 only in the employee's exit month |
| HeadcountFlag | Always 1 — sum this for headcount |

## Validated Numbers (sql-scripts/06_validation_queries.sql)

| Metric | Value |
|---|---|
| December 2026 Headcount | 27 |
| Total Attritions (2026) | 4 |
| Average Salary (December) | 79,370.37 |
| Headcount by Department | Sales 9 / Engineering 9 / HR 9 |
| Headcount by Region | India 15 / USA 12 |

**These are the numbers Power BI's cards/visuals must match once built —
this is your Stage 8 validation reference.**

## Power BI Modeling Notes

- Connect Power BI Desktop to all 5 tables (not a pre-joined view) —
  build relationships in Power BI itself for Modeling practice.
- Relationships: `FactEmployeeSnapshot` is many-to-one with each
  dimension. Mark `DimDate` as a Date Table.
- Suggested core measures: `Total Headcount` (SUM of HeadcountFlag),
  `Attrition Count` (SUM of AttritionFlag), `Average Salary`
  (AVERAGE of Salary, filtered to latest month), `Headcount by
  Department`, `Gender Split %`.
