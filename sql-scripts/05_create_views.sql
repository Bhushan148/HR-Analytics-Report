USE HRAnalytics;
GO

CREATE OR ALTER VIEW dbo.vw_EmployeeSnapshotEnriched
AS
SELECT
    f.SnapshotKey,
    f.SnapshotDate,
    e.EmployeeKey,
    e.EmployeeID,
    e.EmployeeName,
    e.Gender,
    e.EmploymentType,
    e.HireType,
    e.EducationLevel,
    e.MaritalStatus,
    e.WorkMode,
    e.HireDate,
    e.ExitDate,
    e.EmployeeStatus,
    e.ExitReason,
    d.ServiceLine,
    d.Practice,
    d.DepartmentName,
    d.DepartmentType,
    d.IsClientFacing,
    l.City,
    l.StateName,
    l.Region,
    l.Country,
    l.OfficeType,
    j.JobTitle,
    j.CareerLevel,
    j.JobFamily,
    j.EmployeeCategory,
    j.TargetUtilizationPct,
    f.AnnualBaseSalaryLocal,
    f.CurrencyCode,
    f.AnnualBaseSalaryUSD,
    f.SalaryIncreasePct,
    f.BonusAmountUSD,
    f.PerformanceRating,
    f.PerformanceCategory,
    f.EngagementScore,
    f.EngagementCategory,
    f.TenureMonths,
    f.TenureBand,
    f.AvailableHours,
    f.BillableHours,
    f.UtilizationPct,
    f.ProjectStatus,
    f.BenchFlag,
    f.BenchDays,
    f.ProjectAssignmentCount,
    f.TrainingHours,
    f.HeadcountFlag,
    f.NewHireFlag,
    f.ExitFlag,
    f.PromotionFlag,
    f.TransferFlag,
    f.SalaryChangeFlag,
    f.MovementType
FROM dbo.FactEmployeeSnapshot f
JOIN dbo.DimEmployee e ON e.EmployeeKey=f.EmployeeKey
JOIN dbo.DimDepartment d ON d.DepartmentKey=f.DepartmentKey
JOIN dbo.DimLocation l ON l.LocationKey=f.LocationKey
JOIN dbo.DimJob j ON j.JobKey=f.JobKey;
GO

CREATE OR ALTER VIEW dbo.vw_MonthlyWorkforceKPI
AS
SELECT
    SnapshotDate,
    COUNT(*) AS Headcount,
    SUM(CAST(NewHireFlag AS INT)) AS NewHires,
    SUM(CAST(ExitFlag AS INT)) AS Exits,
    SUM(CAST(PromotionFlag AS INT)) AS Promotions,
    SUM(CAST(TransferFlag AS INT)) AS Transfers,
    SUM(CASE WHEN ProjectStatus='Billable' THEN 1 ELSE 0 END) AS BillableEmployees,
    SUM(CAST(BenchFlag AS INT)) AS BenchEmployees,
    CAST(AVG(UtilizationPct) AS DECIMAL(6,2)) AS AvgUtilizationPct,
    CAST(AVG(CAST(EngagementScore AS DECIMAL(6,2))) AS DECIMAL(6,2)) AS AvgEngagementScore,
    CAST(AVG(CAST(PerformanceRating AS DECIMAL(6,2))) AS DECIMAL(6,2)) AS AvgPerformanceRating
FROM dbo.FactEmployeeSnapshot
GROUP BY SnapshotDate;
GO
