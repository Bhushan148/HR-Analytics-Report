USE HRAnalytics;
GO

-- 1. Basic row counts
SELECT 'DimEmployee' AS TableName, COUNT(*) AS [RowCount] FROM dbo.DimEmployee
UNION ALL SELECT 'DimDepartment', COUNT(*) FROM dbo.DimDepartment
UNION ALL SELECT 'DimLocation', COUNT(*) FROM dbo.DimLocation
UNION ALL SELECT 'DimJob', COUNT(*) FROM dbo.DimJob
UNION ALL SELECT 'FactEmployeeSnapshot', COUNT(*) FROM dbo.FactEmployeeSnapshot;

-- 2. Snapshot period and monthly headcount
SELECT MIN(SnapshotDate) AS FirstSnapshot, MAX(SnapshotDate) AS LastSnapshot, COUNT(DISTINCT SnapshotDate) AS SnapshotMonths
FROM dbo.FactEmployeeSnapshot;

SELECT SnapshotDate, COUNT(*) AS Headcount, SUM(CAST(NewHireFlag AS INT)) AS Hires, SUM(CAST(ExitFlag AS INT)) AS Exits
FROM dbo.FactEmployeeSnapshot
GROUP BY SnapshotDate
ORDER BY SnapshotDate;

-- 3. Duplicate grain check: should return zero rows
SELECT EmployeeKey, SnapshotDate, COUNT(*) AS DuplicateCount
FROM dbo.FactEmployeeSnapshot
GROUP BY EmployeeKey, SnapshotDate
HAVING COUNT(*) > 1;

-- 4. No snapshot before hire or after exit: should return zero
SELECT TOP (100) f.EmployeeKey, f.SnapshotDate, e.HireDate, e.ExitDate
FROM dbo.FactEmployeeSnapshot f
JOIN dbo.DimEmployee e ON e.EmployeeKey=f.EmployeeKey
WHERE f.SnapshotDate < DATEFROMPARTS(YEAR(e.HireDate),MONTH(e.HireDate),1)
   OR (e.ExitDate IS NOT NULL AND f.SnapshotDate > DATEFROMPARTS(YEAR(e.ExitDate),MONTH(e.ExitDate),1));

-- 5. New hire and exit flags must match employee dates
SELECT TOP (100) f.EmployeeKey, f.SnapshotDate, f.NewHireFlag, f.ExitFlag, e.HireDate, e.ExitDate
FROM dbo.FactEmployeeSnapshot f
JOIN dbo.DimEmployee e ON e.EmployeeKey=f.EmployeeKey
WHERE (f.NewHireFlag=1 AND f.SnapshotDate<>DATEFROMPARTS(YEAR(e.HireDate),MONTH(e.HireDate),1))
   OR (f.ExitFlag=1 AND (e.ExitDate IS NULL OR f.SnapshotDate<>DATEFROMPARTS(YEAR(e.ExitDate),MONTH(e.ExitDate),1)));

-- 6. Utilization / bench consistency
SELECT TOP (100) *
FROM dbo.FactEmployeeSnapshot
WHERE UtilizationPct < 0 OR UtilizationPct > 110
   OR BillableHours > AvailableHours * 1.10
   OR (BenchFlag=1 AND ProjectStatus<>'Bench')
   OR (BenchFlag=0 AND ProjectStatus='Bench');

-- 7. Distribution checks
SELECT ServiceLine, COUNT(*) AS LatestHeadcount
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=(SELECT MAX(SnapshotDate) FROM dbo.FactEmployeeSnapshot)
GROUP BY ServiceLine
ORDER BY LatestHeadcount DESC;

SELECT CareerLevel, COUNT(*) AS LatestHeadcount
FROM dbo.vw_EmployeeSnapshotEnriched
WHERE SnapshotDate=(SELECT MAX(SnapshotDate) FROM dbo.FactEmployeeSnapshot)
GROUP BY CareerLevel
ORDER BY CASE CareerLevel WHEN 'Analyst' THEN 1 WHEN 'Consultant' THEN 2 WHEN 'Senior Consultant' THEN 3 WHEN 'Manager' THEN 4 WHEN 'Senior Manager' THEN 5 ELSE 6 END;

SELECT ProjectStatus, COUNT(*) AS [Rows], CAST(AVG(UtilizationPct) AS DECIMAL(6,2)) AS AvgUtilization
FROM dbo.FactEmployeeSnapshot
GROUP BY ProjectStatus
ORDER BY Rows DESC;
GO
