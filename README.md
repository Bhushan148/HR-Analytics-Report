# Consulting Workforce & HR Analytics — Power BI Project

**Toolchain: Azure Repos (Source Control) + GitHub (Public Showcase Mirror) + Jira (Tracking)**

**Repo (primary):** https://dev.azure.com/208255258-PowerBI/PowerBI%20Portfolio%20Projects/_git/HR%20Analytics
**Public showcase mirror:** https://github.com/Bhushan148/hr-analytics-github
**Jira board:** https://bhushan148.atlassian.net/jira/software/projects/HA/board

## Purpose

Ye ek personal lab project hai jiska goal Power BI Analyst ka **poora
end-to-end workflow** hands-on practice karna hai — sirf report design nahi,
balki requirement se le kar Power BI Service publish / RLS / deployment tak.

Scenario ek **consulting / professional-services company** ka hai:
Data Engineering team ne ek curated SQL Server dimensional model handoff kiya,
aur mera kaam (Power BI / Data Analyst) us layer se start hota hai — validate,
model, DAX, 2-page report, Dynamic RLS, aur secured delivery.

Full end-to-end spec: **[docs/Consulting_Workforce_HR_Analytics_PowerBI_Project_Blueprint.md](docs/Consulting_Workforce_HR_Analytics_PowerBI_Project_Blueprint.md)**

## Tech Stack

| Layer | Tool |
|---|---|
| Requirement Tracking | Jira |
| Data Source | MS SQL Server — `HRAnalytics` (curated dimensional model) |
| Version Control | Git |
| Remote Repository (primary) | Azure Repos (Azure DevOps) |
| Public Showcase Mirror | GitHub (public — `git push github --all` + `--tags`) |
| Report/Model Development | Power BI Desktop (PBIP + TMDL) |
| Date Dimension | Created in Power BI via DAX (no SQL date table) |
| Service ↔ Repo Sync | Power BI Service Git Integration (Azure Repos) |
| Publishing / Sharing | Power BI Service |
| Security | Dynamic Row-Level Security (Country × Service Line) |
| Environment Promotion | Deployment Pipeline (or manual DEV/TEST/PROD workspaces) |

**Source control model:** `origin` = Azure Repos (private, all real work).
`github` = GitHub (public mirror for portfolio) — pushed at the end with
`git push github --all` + `git push github --tags`.

## Data Scope

Enterprise-scale **synthetic** dataset (not any real firm's data),
professional-services workforce theme. **Live in `HRAnalytics`
(local SQL Server):**

```
DimEmployee            ~720 employees (Gender, EmploymentType, HireType,
                        WorkMode, HireDate/ExitDate, EmployeeStatus, Age, ...)
DimDepartment           ServiceLine -> Practice, IsClientFacing
                        (5 Service Lines: Consulting, Technology,
                         Risk & Compliance, Business Operations,
                         Internal Corporate Services)
DimLocation             City / State / Region / Country (India, USA)
DimJob                  CareerLevel (Analyst -> Director), JobFamily,
                        TargetUtilizationPct
FactEmployeeSnapshot    grain = one employee x one month; 36 monthly
                        snapshots (2023-10 .. 2026-09) -> tens of thousands
                        of rows (utilization, bench, engagement, performance,
                        movement flags, compensation)
SecurityUserAccess      disconnected RLS mapping — one user x Country x
                        Service Line allowed combination
```

**DimDate** is built inside Power BI via DAX (blueprint §12). Validation via
`sql-scripts/06_validation_queries.sql`, `07_business_analysis_queries.sql`,
and views `vw_MonthlyWorkforceKPI` / `vw_EmployeeSnapshotEnriched`. To build
the whole DB in one go, run `sql-scripts/00_run_all.sql` (or
`HRAnalytics_Full_Setup.sql`). Table-by-table notes:
`sql-scripts/README.txt` and `docs/data-model.md`.

## Report Scope

**2-page executive report** (intentionally not a large dashboard) — secured
with one **Dynamic RLS** role at the Country × Service Line grain:

- **Page 1 — Workforce & Utilization Overview:** headcount, billable,
  utilization vs target, bench, Service Line mix, career pyramid, locations
- **Page 2 — Talent & Attrition Insights:** attrition trend/by Service Line/
  by career level, tenure, engagement, performance, promotions, bench exposure

Full visual-by-visual spec, KPIs, slicer panel, and DAX in the blueprint
(§14–§37).

## Complete Workflow — 18 Stages

| # | Stage | Tool | Status |
|---|---|---|---|
| 1 | Requirement | Jira | ✅ Done — ticket HA-1 |
| 2 | Data Source Setup | MS SQL Server | ✅ Done — HRAnalytics (~720 emp × 36 months) |
| 3 | Version Control (branch + push) | Git + Azure Repos | ✅ Done — repo on Azure DevOps (GitHub kept as public mirror) |
| 4 | Power Query | Power BI Desktop | ⬜ Rebuild on new dataset |
| 5 | Data Modeling (+ DAX Date table) | Power BI Desktop | ⬜ Rebuild on new dataset |
| 6 | DAX Measures | Power BI Desktop | ⬜ Rebuild on new dataset |
| 7 | Report Design (2 pages) | Power BI Desktop | ⬜ Pending |
| 8 | Validation | SQL Server | ⬜ Pending |
| 9 | Commit + Push + PR | Git + Azure Repos | ⬜ Pending |
| 10 | Power BI Service ↔ Git Integration | Power BI Service + Azure Repos | ⬜ Pending |
| 11 | Publish (DEV Workspace) | Power BI Service | ⬜ Pending |
| 12 | Scheduled Refresh + Gateway | Power BI Service | ⬜ Pending |
| 13 | RLS (Dynamic, Country × Service Line) | Power BI Desktop + Service | ⬜ Pending |
| 14 | Testing (Technical + UAT) | TEST/UAT Workspace | ⬜ Pending |
| 15 | Deployment (DEV→TEST→PROD) | Deployment Pipeline | ⬜ Pending |
| 16 | Power BI App | Power BI Service | ⬜ Pending |
| 17 | Ticket Close | Jira | ⬜ Pending |
| 18 | Break-Fix Practice (bonus) | All | ⬜ Pending |

> **Note:** The dataset was upgraded (commits [104]/[105]) from the original
> 30-employee lab to the enterprise-scale HRAnalytics model. The
> Power BI model, DAX, and report are being **(re)built on this new dataset**,
> so Stages 4–7 are open again. The end-to-end reasoning for each stage lives
> in the blueprint and `docs/requirements.md`.

## Division of Work

| Area | Kaun Karega |
|---|---|
| SQL Server setup (DB, tables, data) | User/Claude (scripts in `sql-scripts/`) |
| Git local commits | Claude |
| Azure Repos push / PR merge / GitHub showcase mirror | User (credential-based) |
| Power Query / Modeling / DAX / Report | User (Desktop mein, Claude guidance/DAX code deta hai) |
| Dynamic RLS (design/test) | User (Desktop + Service), Claude guides DAX + persona tests |
| Power BI Service (Publish/Refresh/Deploy/App/Git Integration) | User (browser/login-based, Claude step-by-step guide karta hai) |

## Folder Structure

```
HR Analytics/
│
├── HR Analytics.pbip             (Power BI Project file)
├── HR Analytics.Report/          (report definition — text)
├── HR Analytics.SemanticModel/   (semantic model — TMDL: tables, measures, RLS)
│
├── sql-scripts/                  (SQL Server data layer)
│     ├── 00_run_all.sql                     (orchestrator — runs 01..06)
│     ├── 01_create_database_and_tables.sql
│     ├── 02_populate_dimensions.sql
│     ├── 03_populate_employees.sql
│     ├── 04_populate_fact_employee_snapshot.sql
│     ├── 05_create_views.sql                (vw_MonthlyWorkforceKPI, ...)
│     ├── 06_validation_queries.sql
│     ├── 07_business_analysis_queries.sql
│     ├── 08_create_rls_security_mapping.sql (SecurityUserAccess)
│     └── README.txt
│
├── report/                       (Power BI-style HTML report, Full HD)
│     ├── HR_Analytics_Report.html
│     └── data.js                            (data extract powering the report)
│
├── docs/
│     ├── Consulting_Workforce_HR_Analytics_PowerBI_Project_Blueprint.md
│     ├── data-model.md                    (star schema + table notes)
│     ├── requirements.md                   (requirement / ticket notes)
│     ├── interview-prep.md                  (Interview Q&A per stage)
│     └── interview-answer-style-guide.md    (tone/format rules)
│
├── assets/                       (logo, report screenshots)
├── .gitignore
└── README.md
```

> Not committed (see `.gitignore`): `*.pbix` (binary — PBIP is the source),
> the generated `HRAnalytics_Full_Setup.sql` dump, Power BI auto date/time
> tables, and `.pbi/` caches.

## Interview Prep

**[docs/interview-prep.md](docs/interview-prep.md)** — one running file,
organized by stage, updated every time a stage completes. Every question
comes from a real decision or a real bug hit while building this project —
never generic theory. Answers are written in a natural, slightly hesitant
spoken tone (not a polished essay) and are tool-agnostic — each stage names
the specific tool used here but also notes that the same process applies with
any equivalent tool, plus a "what if you didn't have this tool" resilience
question. The exact tone/format rules are in
[docs/interview-answer-style-guide.md](docs/interview-answer-style-guide.md)
— read that before adding new Q&A so future stages stay consistent. The
blueprint's §50 also has a ready spoken project walkthrough.

## Status

Foundation done: Jira ticket, **Azure Repos** source control (GitHub kept as
public showcase mirror), the full **HRAnalytics** SQL data layer
(~720 employees × 36 monthly snapshots, 5 reporting tables + SecurityUserAccess
for RLS), and the end-to-end **project blueprint**. The Power BI build now
starts on this new dataset — next up: **Stage 4 (Power Query) → Stage 5
(model + DAX Date table) → Stage 6 (DAX measures)**, all against
HRAnalytics. This README is updated after every stage — check the
table above for current progress.
