/*
================================================================================
FILE: 08_create_rls_security_mapping.sql
PROJECT: Consulting Workforce & HR Analytics
DATABASE: HRAnalytics

FINAL RLS DESIGN
----------------
ONE Power BI role:
    Dynamic_RLS

ONE SQL security mapping table:
    dbo.SecurityUserAccess

Security grain:
    One UserUPN x Country x ServiceLine allowed combination

Example:
    user@company.com | India | Consulting
    user@company.com | USA   | Technology

The user can see ONLY:
    India + Consulting
    USA   + Technology

The user must NOT automatically receive:
    India + Technology
    USA   + Consulting

This exact-combination behavior is why Country and Service Line are stored
together in the same security mapping table.

GLOBAL ACCESS
-------------
A global user is still assigned to the SAME Dynamic_RLS role.

Full access is represented by all valid Country x ServiceLine combinations.

Current model:
    2 Countries x 5 Service Lines = 10 combinations

This avoids maintaining a separate unrestricted Power BI role.

IMPORTANT
---------
This script creates the SQL security mapping table and test mappings.

Power BI RLS itself is configured in Power BI Desktop using the DAX rules
included at the bottom of this file.

================================================================================
*/

USE HRAnalytics;
GO

SET NOCOUNT ON;
GO


/*==============================================================================
  1. DROP OLD SECURITY OBJECTS FROM PREVIOUS DESIGN
==============================================================================*/

IF OBJECT_ID('dbo.vw_SecurityUserServiceLineActive', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SecurityUserServiceLineActive;
GO

IF OBJECT_ID('dbo.SecurityUserServiceLine', 'U') IS NOT NULL
    DROP TABLE dbo.SecurityUserServiceLine;
GO

IF OBJECT_ID('dbo.vw_SecurityUserAccessActive', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SecurityUserAccessActive;
GO

IF OBJECT_ID('dbo.SecurityUserAccess', 'U') IS NOT NULL
    DROP TABLE dbo.SecurityUserAccess;
GO


/*==============================================================================
  2. CREATE COMBINED COUNTRY x SERVICE LINE SECURITY TABLE
==============================================================================*/

CREATE TABLE dbo.SecurityUserAccess
(
    SecurityAccessKey INT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_SecurityUserAccess PRIMARY KEY,

    UserUPN NVARCHAR(255) NOT NULL,

    Country NVARCHAR(100) NOT NULL,

    ServiceLine NVARCHAR(100) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_SecurityUserAccess_IsActive DEFAULT (1),

    CreatedAt DATETIME2(0) NOT NULL
        CONSTRAINT DF_SecurityUserAccess_CreatedAt DEFAULT (SYSDATETIME()),

    UpdatedAt DATETIME2(0) NULL,

    CONSTRAINT UQ_SecurityUserAccess
        UNIQUE (UserUPN, Country, ServiceLine),

    CONSTRAINT CK_SecurityUserAccess_Country
        CHECK
        (
            Country IN
            (
                'India',
                'USA'
            )
        ),

    CONSTRAINT CK_SecurityUserAccess_ServiceLine
        CHECK
        (
            ServiceLine IN
            (
                'Consulting',
                'Technology',
                'Risk & Compliance',
                'Business Operations',
                'Internal Corporate Services'
            )
        )
);
GO


/*==============================================================================
  3. INDEX FOR DYNAMIC RLS LOOKUPS
==============================================================================*/

CREATE INDEX IX_SecurityUserAccess_UPN_Country_ServiceLine
ON dbo.SecurityUserAccess
(
    UserUPN,
    IsActive,
    Country,
    ServiceLine
);
GO


/*==============================================================================
  4. SAMPLE USERS COVERING REAL RLS SCENARIOS

  All names / UPNs are synthetic for learning.

  Scenario A - Country-only style access
      India HRBP:
      India + all 5 Service Lines

  Scenario B - Service-Line-only style access
      Global Consulting Leader:
      Consulting across India + USA

  Scenario C - Exact Country + Service Line
      India Technology Leader:
      India + Technology only

  Scenario D - Multiple Service Lines in one Country
      India Resource Manager:
      India + Consulting
      India + Technology

  Scenario E - Same Service Line across multiple Countries
      Global Risk Leader:
      India + Risk & Compliance
      USA   + Risk & Compliance

  Scenario F - Different Service Lines in different Countries
      Regional Portfolio Leader:
      India + Consulting
      USA   + Technology

  Scenario G - Global access
      Global HR Head:
      all 10 Country x Service Line combinations
==============================================================================*/


/*------------------------------------------------------------------------------
  Scenario A
  India HRBP -> all Service Lines, India only
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('india.hrbp@contoso-consulting.com', 'India', 'Consulting'),
('india.hrbp@contoso-consulting.com', 'India', 'Technology'),
('india.hrbp@contoso-consulting.com', 'India', 'Risk & Compliance'),
('india.hrbp@contoso-consulting.com', 'India', 'Business Operations'),
('india.hrbp@contoso-consulting.com', 'India', 'Internal Corporate Services');
GO


/*------------------------------------------------------------------------------
  Scenario B
  Global Consulting Leader -> Consulting in both Countries
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('consulting.lead@contoso-consulting.com', 'India', 'Consulting'),
('consulting.lead@contoso-consulting.com', 'USA',   'Consulting');
GO


/*------------------------------------------------------------------------------
  Scenario C
  India Technology Leader -> India + Technology only
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('india.technology.lead@contoso-consulting.com', 'India', 'Technology');
GO


/*------------------------------------------------------------------------------
  Scenario D
  India Resource Manager -> Consulting + Technology in India
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('india.resource.manager@contoso-consulting.com', 'India', 'Consulting'),
('india.resource.manager@contoso-consulting.com', 'India', 'Technology');
GO


/*------------------------------------------------------------------------------
  Scenario E
  Global Risk Leader -> Risk & Compliance in both Countries
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('global.risk.lead@contoso-consulting.com', 'India', 'Risk & Compliance'),
('global.risk.lead@contoso-consulting.com', 'USA',   'Risk & Compliance');
GO


/*------------------------------------------------------------------------------
  Scenario F
  Different Service Lines in different Countries

  IMPORTANT:
  This user is allowed:
      India + Consulting
      USA   + Technology

  This user is NOT allowed:
      India + Technology
      USA   + Consulting
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('portfolio.lead@contoso-consulting.com', 'India', 'Consulting'),
('portfolio.lead@contoso-consulting.com', 'USA',   'Technology');
GO


/*------------------------------------------------------------------------------
  Scenario G
  Global HR Head -> complete company access

  Current combinations:
      2 Countries x 5 Service Lines = 10 rows

  This user still uses the SAME Dynamic_RLS role.
------------------------------------------------------------------------------*/
INSERT INTO dbo.SecurityUserAccess (UserUPN, Country, ServiceLine)
VALUES
('global.hr@contoso-consulting.com', 'India', 'Consulting'),
('global.hr@contoso-consulting.com', 'India', 'Technology'),
('global.hr@contoso-consulting.com', 'India', 'Risk & Compliance'),
('global.hr@contoso-consulting.com', 'India', 'Business Operations'),
('global.hr@contoso-consulting.com', 'India', 'Internal Corporate Services'),

('global.hr@contoso-consulting.com', 'USA', 'Consulting'),
('global.hr@contoso-consulting.com', 'USA', 'Technology'),
('global.hr@contoso-consulting.com', 'USA', 'Risk & Compliance'),
('global.hr@contoso-consulting.com', 'USA', 'Business Operations'),
('global.hr@contoso-consulting.com', 'USA', 'Internal Corporate Services');
GO


/*==============================================================================
  5. ACTIVE SECURITY VIEW

  Power BI can import the base table directly.

  This view is useful for checking only currently active access mappings.
==============================================================================*/

CREATE OR ALTER VIEW dbo.vw_SecurityUserAccessActive
AS
SELECT
    SecurityAccessKey,
    UserUPN,
    Country,
    ServiceLine
FROM dbo.SecurityUserAccess
WHERE IsActive = 1;
GO


/*==============================================================================
  6. VALIDATION QUERIES
==============================================================================*/

-- A. Review all active access combinations
SELECT
    UserUPN,
    Country,
    ServiceLine
FROM dbo.SecurityUserAccess
WHERE IsActive = 1
ORDER BY
    UserUPN,
    Country,
    ServiceLine;
GO


-- B. Access-combination count per user
SELECT
    UserUPN,
    COUNT(*) AS AllowedCombinationCount
FROM dbo.SecurityUserAccess
WHERE IsActive = 1
GROUP BY
    UserUPN
ORDER BY
    UserUPN;
GO


-- C. Country count and Service Line count by user
SELECT
    UserUPN,
    COUNT(DISTINCT Country) AS AllowedCountryCount,
    COUNT(DISTINCT ServiceLine) AS AllowedServiceLineCount,
    COUNT(*) AS ExactAllowedCombinationCount
FROM dbo.SecurityUserAccess
WHERE IsActive = 1
GROUP BY
    UserUPN
ORDER BY
    UserUPN;
GO


-- D. Validate that every security Country exists in DimLocation
SELECT DISTINCT
    S.Country
FROM dbo.SecurityUserAccess AS S
LEFT JOIN
(
    SELECT DISTINCT Country
    FROM dbo.DimLocation
) AS L
    ON L.Country = S.Country
WHERE L.Country IS NULL;
GO

-- Expected result: 0 rows.


-- E. Validate that every security Service Line exists in DimDepartment
SELECT DISTINCT
    S.ServiceLine
FROM dbo.SecurityUserAccess AS S
LEFT JOIN
(
    SELECT DISTINCT ServiceLine
    FROM dbo.DimDepartment
) AS D
    ON D.ServiceLine = S.ServiceLine
WHERE D.ServiceLine IS NULL;
GO

-- Expected result: 0 rows.


-- F. Show current valid Countries
SELECT DISTINCT
    Country
FROM dbo.DimLocation
ORDER BY
    Country;
GO


-- G. Show current valid Service Lines
SELECT DISTINCT
    ServiceLine
FROM dbo.DimDepartment
ORDER BY
    ServiceLine;
GO


-- H. Verify Global HR has all 10 combinations
SELECT
    UserUPN,
    COUNT(*) AS CombinationCount
FROM dbo.SecurityUserAccess
WHERE
    UserUPN = 'global.hr@contoso-consulting.com'
    AND IsActive = 1
GROUP BY
    UserUPN;
GO

-- Expected:
-- CombinationCount = 10


/*==============================================================================
  7. EXAMPLE SECURITY MAINTENANCE
==============================================================================*/

-- Add exact access:
-- INSERT INTO dbo.SecurityUserAccess
-- (
--     UserUPN,
--     Country,
--     ServiceLine
-- )
-- VALUES
-- (
--     'new.user@contoso-consulting.com',
--     'India',
--     'Consulting'
-- );


-- Add another Country + Service Line combination:
-- INSERT INTO dbo.SecurityUserAccess
-- (
--     UserUPN,
--     Country,
--     ServiceLine
-- )
-- VALUES
-- (
--     'new.user@contoso-consulting.com',
--     'USA',
--     'Technology'
-- );


-- Temporarily disable one exact access combination:
-- UPDATE dbo.SecurityUserAccess
-- SET
--     IsActive = 0,
--     UpdatedAt = SYSDATETIME()
-- WHERE UserUPN = 'new.user@contoso-consulting.com'
--   AND Country = 'USA'
--   AND ServiceLine = 'Technology';


-- Re-enable access:
-- UPDATE dbo.SecurityUserAccess
-- SET
--     IsActive = 1,
--     UpdatedAt = SYSDATETIME()
-- WHERE UserUPN = 'new.user@contoso-consulting.com'
--   AND Country = 'USA'
--   AND ServiceLine = 'Technology';


-- Permanently remove one exact access combination:
-- DELETE FROM dbo.SecurityUserAccess
-- WHERE UserUPN = 'new.user@contoso-consulting.com'
--   AND Country = 'USA'
--   AND ServiceLine = 'Technology';


/*==============================================================================
  8. POWER BI MODEL SETUP
==============================================================================

LOAD INTO POWER BI
------------------
Import:

    dbo.SecurityUserAccess

Keep SecurityUserAccess DISCONNECTED from the business star schema.

Existing model remains:

    DimEmployee
         |
         |
    FactEmployeeSnapshot
      /       |        \
DimDepartment |      DimJob
              |
         DimLocation

plus:
    DimDate

and disconnected:
    SecurityUserAccess


CREATE ONLY ONE ROLE
--------------------
Power BI role name:

    Dynamic_RLS


WHY ONE ROLE?
-------------
All access scenarios are represented in SecurityUserAccess.

Do not create:
    India_Access
    USA_Access
    Consulting_Access
    Technology_Access
    Global_Access

The user should belong only to Dynamic_RLS.

================================================================================
  9. POWER BI DAX RLS RULES
================================================================================

For the best user experience, apply THREE filters inside the SAME Dynamic_RLS
role:

    A. DimLocation
    B. DimDepartment
    C. FactEmployeeSnapshot

The dimension rules hide countries / service lines the user has no access to.

The fact rule is CRITICAL because it enforces the exact Country x ServiceLine
combination and prevents accidental cross-combinations.


-------------------------------------------------------------------------------
A. FILTER ON DimLocation
-------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------
B. FILTER ON DimDepartment
-------------------------------------------------------------------------------

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


-------------------------------------------------------------------------------
C. EXACT COMBINATION FILTER ON FactEmployeeSnapshot
-------------------------------------------------------------------------------

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


WHY THE FACT FILTER IS REQUIRED
-------------------------------
Example security table:

portfolio.lead@contoso-consulting.com
    India + Consulting
    USA   + Technology

If Power BI only filters Countries and Service Lines independently:

Allowed Countries:
    India
    USA

Allowed Service Lines:
    Consulting
    Technology

That could create a logical cross-product:

    India + Consulting       VALID
    India + Technology       NOT VALID
    USA   + Consulting       NOT VALID
    USA   + Technology       VALID

The FactEmployeeSnapshot rule checks BOTH values together for every fact row.

Therefore only the exact combinations stored in SecurityUserAccess survive.


================================================================================
  10. EXPECTED USER SCENARIOS
================================================================================

USER:
india.hrbp@contoso-consulting.com

ACCESS:
    India + Consulting
    India + Technology
    India + Risk & Compliance
    India + Business Operations
    India + Internal Corporate Services

RESULT:
    All Service Lines in India
    No USA data


USER:
consulting.lead@contoso-consulting.com

ACCESS:
    India + Consulting
    USA   + Consulting

RESULT:
    Consulting globally
    No Technology / Risk / Operations / Corporate Services


USER:
india.technology.lead@contoso-consulting.com

ACCESS:
    India + Technology

RESULT:
    Technology in India only


USER:
india.resource.manager@contoso-consulting.com

ACCESS:
    India + Consulting
    India + Technology

RESULT:
    Consulting + Technology in India


USER:
global.risk.lead@contoso-consulting.com

ACCESS:
    India + Risk & Compliance
    USA   + Risk & Compliance

RESULT:
    Risk & Compliance across both Countries


USER:
portfolio.lead@contoso-consulting.com

ACCESS:
    India + Consulting
    USA   + Technology

RESULT:
    India + Consulting
    USA   + Technology

DOES NOT RECEIVE:
    India + Technology
    USA   + Consulting


USER:
global.hr@contoso-consulting.com

ACCESS:
    All 10 combinations

RESULT:
    Full company data

Still uses:
    Dynamic_RLS


================================================================================
  11. POWER BI SERVICE
================================================================================

After publishing:

1. Open the semantic model security settings.
2. Add all approved report consumers to:
       Dynamic_RLS

3. Keep their Country + ServiceLine permissions in:
       dbo.SecurityUserAccess

4. Do not maintain different Power BI roles for each access combination.

5. Restricted business users should normally consume the report as
   Viewer / App consumers.

6. Test representative personas before production release.

Suggested test users:
    india.hrbp@contoso-consulting.com
    consulting.lead@contoso-consulting.com
    india.technology.lead@contoso-consulting.com
    portfolio.lead@contoso-consulting.com
    global.hr@contoso-consulting.com


================================================================================
  12. LEARNING NOTE
================================================================================

This project intentionally uses a disconnected security table plus an exact
fact-level combination check because it demonstrates an important RLS problem:

Independent permissions do NOT always represent combination permissions.

Security requirement:
    Country x Service Line

must be evaluated at the same grain as the permission itself.

For much larger enterprise semantic models, a dedicated security-scope bridge
or governed authorization dimension can be considered. For this learning
project, the current approach is clear, auditable, and appropriate for the
dataset size.

================================================================================
END OF FILE
================================================================================
*/

PRINT 'Combined Country x Service Line RLS security mapping created successfully.';
GO
