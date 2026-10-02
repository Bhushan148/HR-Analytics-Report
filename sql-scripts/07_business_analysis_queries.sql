USE HRAnalytics;
GO

-- 1. Current workforce by service line and practice
DECLARE @LatestDate DATE=(SELECT MAX(SnapshotDate) FROM dbo.FactEmployeeSnapshot);
SELECT ServiceLine, Practice, COUNT(*) AS Headcount
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=@LatestDate
GROUP BY ServiceLine, Practice
ORDER BY ServiceLine, Headcount DESC;

-- 2. Monthly headcount, hires and exits
SELECT SnapshotDate, Headcount, NewHires, Exits, Promotions, Transfers
FROM dbo.vw_MonthlyWorkforceKPI
ORDER BY SnapshotDate;

-- 3. Utilization by service line (client-facing practices only)
SELECT ServiceLine,
       CAST(AVG(UtilizationPct) AS DECIMAL(6,2)) AS AvgUtilizationPct,
       SUM(CASE WHEN ProjectStatus='Billable' THEN 1 ELSE 0 END) AS BillableEmployees,
       COUNT(*) AS Employees
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=@LatestDate AND IsClientFacing=1
GROUP BY ServiceLine
ORDER BY AvgUtilizationPct DESC;

-- 4. Bench analysis
SELECT ServiceLine, CareerLevel,
       SUM(CAST(BenchFlag AS INT)) AS BenchEmployees,
       CAST(AVG(CASE WHEN BenchFlag=1 THEN CAST(BenchDays AS DECIMAL(6,2)) END) AS DECIMAL(6,2)) AS AvgBenchDays
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=@LatestDate AND IsClientFacing=1
GROUP BY ServiceLine, CareerLevel
ORDER BY BenchEmployees DESC;

-- 5. Attrition by service line over full period
SELECT ServiceLine,
       SUM(CAST(ExitFlag AS INT)) AS Exits,
       COUNT(DISTINCT EmployeeKey) AS EmployeesObserved,
       CAST(100.0*SUM(CAST(ExitFlag AS INT))/NULLIF(COUNT(DISTINCT EmployeeKey),0) AS DECIMAL(6,2)) AS PeriodExitPct
FROM dbo.vw_EmployeeSnapshotEnriched
GROUP BY ServiceLine
ORDER BY PeriodExitPct DESC;

-- 6. Attrition by career level
SELECT CareerLevel, SUM(CAST(ExitFlag AS INT)) AS Exits
FROM dbo.vw_EmployeeSnapshotEnriched
GROUP BY CareerLevel
ORDER BY Exits DESC;

-- 7. Bench exposure vs exits
WITH EmployeeBench AS (
    SELECT EmployeeKey,
           SUM(BenchDays) AS TotalBenchDays,
           MAX(CAST(ExitFlag AS INT)) AS Exited
    FROM dbo.FactEmployeeSnapshot
    GROUP BY EmployeeKey
)
SELECT CASE WHEN TotalBenchDays=0 THEN 'No Bench'
            WHEN TotalBenchDays<=20 THEN '1-20 Days'
            WHEN TotalBenchDays<=45 THEN '21-45 Days'
            ELSE '46+ Days' END AS BenchExposure,
       COUNT(*) AS Employees,
       SUM(Exited) AS Exits,
       CAST(100.0*SUM(Exited)/COUNT(*) AS DECIMAL(6,2)) AS ExitPct
FROM EmployeeBench
GROUP BY CASE WHEN TotalBenchDays=0 THEN 'No Bench'
              WHEN TotalBenchDays<=20 THEN '1-20 Days'
              WHEN TotalBenchDays<=45 THEN '21-45 Days'
              ELSE '46+ Days' END
ORDER BY ExitPct DESC;

-- 8. Performance and promotions
SELECT PerformanceCategory,
       COUNT(*) AS SnapshotRows,
       SUM(CAST(PromotionFlag AS INT)) AS Promotions,
       CAST(100.0*SUM(CAST(PromotionFlag AS INT))/COUNT(*) AS DECIMAL(6,2)) AS PromotionRowPct
FROM dbo.FactEmployeeSnapshot
GROUP BY PerformanceCategory
ORDER BY MIN(PerformanceRating);

-- 9. Engagement vs exits
SELECT EngagementCategory,
       COUNT(DISTINCT EmployeeKey) AS EmployeesObserved,
       SUM(CAST(ExitFlag AS INT)) AS ExitEvents
FROM dbo.FactEmployeeSnapshot
GROUP BY EngagementCategory
ORDER BY EngagementCategory;

-- 10. Current salary by career level and country
SELECT Country, CareerLevel,
       COUNT(*) AS Employees,
       CAST(AVG(AnnualBaseSalaryUSD) AS DECIMAL(12,2)) AS AvgSalaryUSD
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=@LatestDate
GROUP BY Country, CareerLevel
ORDER BY Country,
         CASE CareerLevel WHEN 'Analyst' THEN 1 WHEN 'Consultant' THEN 2 WHEN 'Senior Consultant' THEN 3 WHEN 'Manager' THEN 4 WHEN 'Senior Manager' THEN 5 ELSE 6 END;

-- 11. Training hours among bench and billable employees
SELECT ProjectStatus,
       COUNT(*) AS SnapshotRows,
       SUM(TrainingHours) AS TrainingHours,
       CAST(AVG(CAST(TrainingHours AS DECIMAL(6,2))) AS DECIMAL(6,2)) AS AvgTrainingHours
FROM dbo.FactEmployeeSnapshot
GROUP BY ProjectStatus
ORDER BY SnapshotRows DESC;

-- 12. Latest workforce by location
SELECT Country, City, COUNT(*) AS Headcount,
       CAST(AVG(UtilizationPct) AS DECIMAL(6,2)) AS AvgUtilizationPct
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=@LatestDate
GROUP BY Country, City
ORDER BY Headcount DESC;
GO
