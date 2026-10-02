SET NOCOUNT ON;
GO

IF DB_ID(N'HRAnalytics') IS NULL
BEGIN
    CREATE DATABASE HRAnalytics;
END;
GO

USE HRAnalytics;
GO

-- Re-runnable learning script: drop fact first, then dimensions.
IF OBJECT_ID(N'dbo.FactEmployeeSnapshot', N'U') IS NOT NULL DROP TABLE dbo.FactEmployeeSnapshot;
IF OBJECT_ID(N'dbo.DimEmployee', N'U') IS NOT NULL DROP TABLE dbo.DimEmployee;
IF OBJECT_ID(N'dbo.DimJob', N'U') IS NOT NULL DROP TABLE dbo.DimJob;
IF OBJECT_ID(N'dbo.DimLocation', N'U') IS NOT NULL DROP TABLE dbo.DimLocation;
IF OBJECT_ID(N'dbo.DimDepartment', N'U') IS NOT NULL DROP TABLE dbo.DimDepartment;
GO

CREATE TABLE dbo.DimDepartment (
    DepartmentKey      INT           NOT NULL PRIMARY KEY,
    DepartmentID       VARCHAR(10)   NOT NULL UNIQUE,
    ServiceLine        VARCHAR(60)   NOT NULL,
    Practice           VARCHAR(80)   NOT NULL,
    DepartmentName     VARCHAR(80)   NOT NULL,
    DepartmentType     VARCHAR(30)   NOT NULL,
    IsClientFacing     BIT           NOT NULL
);
GO

CREATE TABLE dbo.DimLocation (
    LocationKey        INT           NOT NULL PRIMARY KEY,
    LocationID         VARCHAR(10)   NOT NULL UNIQUE,
    City               VARCHAR(60)   NOT NULL,
    StateName          VARCHAR(60)   NOT NULL,
    Region             VARCHAR(60)   NOT NULL,
    Country            VARCHAR(40)   NOT NULL,
    OfficeType         VARCHAR(40)   NOT NULL,
    CurrencyCode       CHAR(3)       NOT NULL
);
GO

CREATE TABLE dbo.DimJob (
    JobKey                    INT           NOT NULL PRIMARY KEY,
    JobCode                   VARCHAR(10)   NOT NULL UNIQUE,
    JobTitle                  VARCHAR(100)  NOT NULL,
    CareerLevel               VARCHAR(30)   NOT NULL,
    JobFamily                 VARCHAR(60)   NOT NULL,
    EmployeeCategory          VARCHAR(40)   NOT NULL,
    TypicalMinSalaryUSD       DECIMAL(12,2) NOT NULL,
    TypicalMaxSalaryUSD       DECIMAL(12,2) NOT NULL,
    TargetUtilizationPct      DECIMAL(5,2)  NOT NULL
);
GO

CREATE TABLE dbo.DimEmployee (
    EmployeeKey           INT            NOT NULL PRIMARY KEY,
    EmployeeID            VARCHAR(10)    NOT NULL UNIQUE,
    EmployeeName          NVARCHAR(100)  NOT NULL,
    Gender                VARCHAR(10)    NOT NULL,
    EmploymentType        VARCHAR(20)    NOT NULL,
    HireType              VARCHAR(30)    NOT NULL,
    EducationLevel        VARCHAR(30)    NOT NULL,
    MaritalStatus         VARCHAR(15)    NOT NULL,
    WorkMode              VARCHAR(15)    NOT NULL,
    HireDate              DATE           NOT NULL,
    ExitDate              DATE           NULL,
    EmployeeStatus        VARCHAR(20)    NOT NULL,
    ExitReason            VARCHAR(40)    NULL,
    Age                    TINYINT        NOT NULL,
    TotalExperienceYears  TINYINT        NOT NULL
);
GO

CREATE TABLE dbo.FactEmployeeSnapshot (
    SnapshotKey           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    EmployeeKey           INT            NOT NULL,
    SnapshotDate          DATE           NOT NULL,
    DepartmentKey         INT            NOT NULL,
    LocationKey           INT            NOT NULL,
    JobKey                INT            NOT NULL,
    AnnualBaseSalaryLocal DECIMAL(14,2)  NOT NULL,
    CurrencyCode          CHAR(3)        NOT NULL,
    FXRateToUSD           DECIMAL(10,4)  NOT NULL,
    AnnualBaseSalaryUSD   DECIMAL(12,2)  NOT NULL,
    SalaryIncreasePct     DECIMAL(6,2)   NOT NULL,
    BonusAmountUSD        DECIMAL(12,2)  NOT NULL,
    PerformanceRating     TINYINT        NOT NULL,
    PerformanceCategory   VARCHAR(40)    NOT NULL,
    EngagementScore       TINYINT        NOT NULL,
    EngagementCategory    VARCHAR(15)    NOT NULL,
    TenureMonths          SMALLINT       NOT NULL,
    TenureBand            VARCHAR(20)    NOT NULL,
    AvailableHours        SMALLINT       NOT NULL,
    BillableHours         SMALLINT       NOT NULL,
    UtilizationPct        DECIMAL(6,2)   NOT NULL,
    ProjectStatus         VARCHAR(20)    NOT NULL,
    BenchFlag             BIT            NOT NULL,
    BenchDays             TINYINT        NOT NULL,
    ProjectAssignmentCount TINYINT       NOT NULL,
    TrainingHours         SMALLINT       NOT NULL,
    HeadcountFlag         BIT            NOT NULL,
    NewHireFlag           BIT            NOT NULL,
    ExitFlag              BIT            NOT NULL,
    PromotionFlag         BIT            NOT NULL,
    TransferFlag          BIT            NOT NULL,
    SalaryChangeFlag      BIT            NOT NULL,
    MovementType          VARCHAR(20)    NOT NULL,
    CONSTRAINT UQ_FactEmployeeSnapshot UNIQUE (EmployeeKey, SnapshotDate),
    CONSTRAINT FK_FactSnapshot_Employee FOREIGN KEY (EmployeeKey) REFERENCES dbo.DimEmployee(EmployeeKey),
    CONSTRAINT FK_FactSnapshot_Department FOREIGN KEY (DepartmentKey) REFERENCES dbo.DimDepartment(DepartmentKey),
    CONSTRAINT FK_FactSnapshot_Location FOREIGN KEY (LocationKey) REFERENCES dbo.DimLocation(LocationKey),
    CONSTRAINT FK_FactSnapshot_Job FOREIGN KEY (JobKey) REFERENCES dbo.DimJob(JobKey),
    CONSTRAINT CK_PerformanceRating CHECK (PerformanceRating BETWEEN 1 AND 5),
    CONSTRAINT CK_EngagementScore CHECK (EngagementScore BETWEEN 0 AND 100),
    CONSTRAINT CK_UtilizationPct CHECK (UtilizationPct BETWEEN 0 AND 110)
);
GO

CREATE INDEX IX_FactSnapshot_Date ON dbo.FactEmployeeSnapshot(SnapshotDate);
CREATE INDEX IX_FactSnapshot_Department ON dbo.FactEmployeeSnapshot(DepartmentKey, SnapshotDate);
CREATE INDEX IX_FactSnapshot_Location ON dbo.FactEmployeeSnapshot(LocationKey, SnapshotDate);
CREATE INDEX IX_FactSnapshot_Job ON dbo.FactEmployeeSnapshot(JobKey, SnapshotDate);
CREATE INDEX IX_FactSnapshot_Employee ON dbo.FactEmployeeSnapshot(EmployeeKey, SnapshotDate);
GO
