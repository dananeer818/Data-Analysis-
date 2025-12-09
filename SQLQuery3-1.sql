/* =========================================================
   FILE 00: Create RAW table + Source VIEW
   ========================================================= */

USE [supply chain];
GO

/* 0.1 إنشاء جدول raw لو مش موجود */

IF OBJECT_ID('dbo.supply_chain_data','U') IS NULL
BEGIN
    PRINT N'🛠 إنشاء جدول dbo.supply_chain_data ...';

    CREATE TABLE dbo.supply_chain_data (
        [Product type]              NVARCHAR(50),
        [SKU]                       NVARCHAR(50),
        [Price]                     DECIMAL(18,4),
        [Availability]              INT,
        [Number of products sold]   INT,
        [Revenue generated]         DECIMAL(18,4),
        [Customer demographics]     NVARCHAR(50),
        [Stock levels]              INT,
        [Lead times]                INT,
        [Order quantities]          INT,
        [Shipping times]            INT,
        [Shipping carriers]         NVARCHAR(50),
        [Shipping costs]            DECIMAL(18,4),
        [Supplier name]             NVARCHAR(100),
        [Location]                  NVARCHAR(100),
        [Lead time]                 INT,
        [Production volumes]        INT,
        [Manufacturing lead time]   INT,
        [Manufacturing costs]       DECIMAL(18,4),
        [Inspection results]        NVARCHAR(50),
        [Defect rates]              DECIMAL(18,4),
        [Transportation modes]      NVARCHAR(50),
        [Routes]                    NVARCHAR(50),
        [Costs]                     DECIMAL(18,4)
    );

    PRINT N'✅ تم إنشاء جدول dbo.supply_chain_data (بدون بيانات).';
   
END
ELSE
BEGIN
    PRINT N'✅ جدول dbo.supply_chain_data موجود بالفعل – لن يتم إنشاؤه.';
END
GO

-- تفريغ الجدول أولاً
TRUNCATE TABLE dbo.supply_chain_data;
GO

PRINT N'📥 بدء تحميل البيانات من ملف CSV...';

-- IMPORTANT: استخدام FIELDTERMINATOR = ',' بدلاً من ';'
BULK INSERT dbo.supply_chain_data
FROM 'c:\supply_chain_data.csv'  -- تأكد أن الملف موجود في C:\
WITH (
    FIRSTROW = 2,                -- تخطي الصف الأول (العناوين)
    FIELDTERMINATOR = ',',       -- ⚠️ هذا هو التصحيح: استخدام فاصلة
    ROWTERMINATOR = '0x0a',      -- استخدام 0x0a لـ \n
    CODEPAGE = '65001',          -- UTF-8
    TABLOCK
);
GO

PRINT N'✅ تم استيراد ' + CAST(@@ROWCOUNT AS NVARCHAR(10)) + ' سطر من بيانات الـ CSV';
GO

/* 0.2 إنشاء الـ VIEW الموحد SupplyChainAnalysis */

IF OBJECT_ID('dbo.SupplyChainAnalysis','V') IS NOT NULL
    DROP VIEW dbo.SupplyChainAnalysis;
GO

CREATE VIEW dbo.SupplyChainAnalysis
AS
SELECT
    [SKU]                      AS SKU,
    [Product type]             AS ProductType,
    [Price]                    AS Price,
    [Availability]             AS Availability,
    [Number of products sold]  AS ProductsSold,
    [Revenue generated]        AS Revenue,
    [Customer demographics]    AS CustomerDemographics,
    [Stock levels]             AS StockLevels,
    [Lead times]               AS LeadTimes,
    [Order quantities]         AS OrderQuantity,
    [Shipping times]           AS ShippingTimes,
    [Shipping carriers]        AS ShippingCarrier,
    [Shipping costs]           AS ShippingCosts,
    [Supplier name]            AS SupplierName,
    [Location]                 AS Location,
    [Lead time]                AS LeadTime,
    [Production volumes]       AS ProductionVolumes,
    [Manufacturing lead time]  AS ManufacturingLeadTime,
    [Manufacturing costs]      AS ManufacturingCosts,
    [Inspection results]       AS InspectionResults,
    [Defect rates]             AS DefectRates,
    [Transportation modes]     AS TransportationModes,
    [Routes]                   AS Routes,
    [Costs]                    AS OtherCosts
FROM dbo.supply_chain_data;
GO

PRINT N'✅ تم إنشاء الـ VIEW dbo.SupplyChainAnalysis بنجاح.';
GO

-- التحقق من البيانات
PRINT N'🔍 التحقق من البيانات المحملة...';
SELECT COUNT(*) AS عدد_الصفوف_المحملة FROM dbo.supply_chain_data;
SELECT TOP 3 * FROM dbo.supply_chain_data;
GO



/* =========================================================
   FILE 01: Create DWH Star Schema Tables
   ========================================================= */

USE [supply chain];
GO

-- تأكيد وجود الـ VIEW
IF OBJECT_ID('dbo.SupplyChainAnalysis','V') IS NULL
BEGIN
    PRINT N'❌ View SupplyChainAnalysis غير موجود. شغّل أولاً FILE 00.';
    RETURN;
END
GO

PRINT N'🔄 مسح الجداول القديمة إن وُجدت...';

IF OBJECT_ID('dbo.FactSupplyChain','U') IS NOT NULL DROP TABLE dbo.FactSupplyChain;
IF OBJECT_ID('dbo.DimTime','U')       IS NOT NULL DROP TABLE dbo.DimTime;
IF OBJECT_ID('dbo.DimShipping','U')   IS NOT NULL DROP TABLE dbo.DimShipping;
IF OBJECT_ID('dbo.DimCustomers','U')  IS NOT NULL DROP TABLE dbo.DimCustomers;
IF OBJECT_ID('dbo.DimSuppliers','U')  IS NOT NULL DROP TABLE dbo.DimSuppliers;
IF OBJECT_ID('dbo.DimProducts','U')   IS NOT NULL DROP TABLE dbo.DimProducts;
GO

PRINT N'🏗️ إنشاء جداول الأبعاد...';

CREATE TABLE dbo.DimProducts (
    ProductID            INT IDENTITY(1,1) PRIMARY KEY,
    SKU                  NVARCHAR(50)  NOT NULL,
    ProductType          NVARCHAR(50)  NOT NULL,
    Price                DECIMAL(18,4) NULL,
    DefectRate           DECIMAL(18,4) NULL,
    ManufacturingCosts   DECIMAL(18,4) NULL,
    CONSTRAINT UQ_DimProducts_SKU UNIQUE (SKU)
);

CREATE TABLE dbo.DimSuppliers (
    SupplierID   INT IDENTITY(1,1) PRIMARY KEY,
    SupplierName NVARCHAR(100) NOT NULL,
    Location     NVARCHAR(100) NULL,
    CONSTRAINT UQ_DimSuppliers UNIQUE (SupplierName, Location)
);

CREATE TABLE dbo.DimCustomers (
    CustomerID           INT IDENTITY(1,1) PRIMARY KEY,
    CustomerDemographics NVARCHAR(50) NOT NULL,
    CONSTRAINT UQ_DimCustomers UNIQUE (CustomerDemographics)
);

CREATE TABLE dbo.DimShipping (
    ShippingID          INT IDENTITY(1,1) PRIMARY KEY,
    ShippingCarrier     NVARCHAR(50)  NOT NULL,
    AverageShippingCost DECIMAL(18,4) NULL,
    CONSTRAINT UQ_DimShipping UNIQUE (ShippingCarrier)
);

CREATE TABLE dbo.DimTime (
    TimeID    INT IDENTITY(1,1) PRIMARY KEY,
    FullDate  DATE     NOT NULL,
    [Day]     TINYINT  NOT NULL,
    [Month]   TINYINT  NOT NULL,
    [Year]    SMALLINT NOT NULL,
    Quarter   CHAR(2)  NOT NULL,
    CONSTRAINT UQ_DimTime UNIQUE (FullDate)
);

PRINT N'💰 إنشاء جدول الحقائق...';

CREATE TABLE dbo.FactSupplyChain (
    FactID             INT IDENTITY(1,1) PRIMARY KEY,

    -- مفاتيح الأبعاد
    ProductID          INT NOT NULL,
    SupplierID         INT NOT NULL,
    CustomerID         INT NOT NULL,
    ShippingID         INT NOT NULL,
    TimeID             INT NOT NULL,

    -- المقاييس
    Availability       INT           NULL,
    StockLevels        INT           NULL,
    ProductsSold       INT           NULL,
    Revenue            DECIMAL(18,4) NULL,
    OrderQuantity      INT           NULL,
    ManufacturingCosts DECIMAL(18,4) NULL,
    ShippingCost       DECIMAL(18,4) NULL,

    -- أعمدة محسوبة
    TotalCost AS (ISNULL(ManufacturingCosts,0) + ISNULL(ShippingCost,0)),
    Profit    AS (ISNULL(Revenue,0) - (ISNULL(ManufacturingCosts,0) + ISNULL(ShippingCost,0))),

    -- العلاقات
    CONSTRAINT FK_Fact_Product  FOREIGN KEY (ProductID)  REFERENCES dbo.DimProducts(ProductID),
    CONSTRAINT FK_Fact_Supplier FOREIGN KEY (SupplierID) REFERENCES dbo.DimSuppliers(SupplierID),
    CONSTRAINT FK_Fact_Customer FOREIGN KEY (CustomerID) REFERENCES dbo.DimCustomers(CustomerID),
    CONSTRAINT FK_Fact_Shipping FOREIGN KEY (ShippingID) REFERENCES dbo.DimShipping(ShippingID),
    CONSTRAINT FK_Fact_Time     FOREIGN KEY (TimeID)     REFERENCES dbo.DimTime(TimeID)
);
GO

PRINT N'✅ تم إنشاء جميع جداول الـ DWH بنجاح.';
GO



/* =========================================================
   FILE 02: Insert Data into Dimensions & Fact
   ========================================================= */

USE [supply chain];
GO

PRINT N'🗑️ مسح البيانات القديمة من جداول DWH...';

-- مسح الحقائق أولاً (بسبب العلاقات)
TRUNCATE TABLE dbo.FactSupplyChain;

-- ثم مسح الأبعاد
DELETE FROM dbo.DimTime;
DELETE FROM dbo.DimShipping;
DELETE FROM dbo.DimCustomers;
DELETE FROM dbo.DimSuppliers;
DELETE FROM dbo.DimProducts;
GO

PRINT N'📥 بدء إدخال البيانات في جداول الـ DWH...';

-----------------------------
-- 1) DimProducts
-----------------------------
PRINT N'📦 إدخال DimProducts...';

INSERT INTO dbo.DimProducts (SKU, ProductType, Price, DefectRate, ManufacturingCosts)
SELECT DISTINCT
    sc.SKU,
    sc.ProductType,
    sc.Price,
    sc.DefectRates,
    sc.ManufacturingCosts
FROM dbo.SupplyChainAnalysis AS sc
WHERE sc.SKU IS NOT NULL;

PRINT N'✅ عدد الصفوف في DimProducts: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-----------------------------
-- 2) DimSuppliers
-----------------------------
PRINT N'🏭 إدخال DimSuppliers...';

INSERT INTO dbo.DimSuppliers (SupplierName, Location)
SELECT DISTINCT
    sc.SupplierName,
    sc.Location
FROM dbo.SupplyChainAnalysis AS sc
WHERE sc.SupplierName IS NOT NULL;

PRINT N'✅ عدد الصفوف في DimSuppliers: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-----------------------------
-- 3) DimCustomers
-----------------------------
PRINT N'👥 إدخال DimCustomers...';

INSERT INTO dbo.DimCustomers (CustomerDemographics)
SELECT DISTINCT
    sc.CustomerDemographics
FROM dbo.SupplyChainAnalysis AS sc
WHERE sc.CustomerDemographics IS NOT NULL;

PRINT N'✅ عدد الصفوف في DimCustomers: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-----------------------------
-- 4) DimShipping
-----------------------------
PRINT N'🚚 إدخال DimShipping...';

INSERT INTO dbo.DimShipping (ShippingCarrier, AverageShippingCost)
SELECT
    sc.ShippingCarrier,
    AVG(sc.ShippingCosts)
FROM dbo.SupplyChainAnalysis AS sc
WHERE sc.ShippingCarrier IS NOT NULL
GROUP BY sc.ShippingCarrier;

PRINT N'✅ عدد الصفوف في DimShipping: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

-----------------------------
-- 5) DimTime
-----------------------------
PRINT N'📅 إدخال DimTime (Snapshot واحد)...';

DECLARE @Today DATE = CONVERT(date, GETDATE());

IF NOT EXISTS (SELECT 1 FROM dbo.DimTime WHERE FullDate = @Today)
BEGIN
    INSERT INTO dbo.DimTime (FullDate, [Day], [Month], [Year], Quarter)
    VALUES (
        @Today,
        DAY(@Today),
        MONTH(@Today),
        YEAR(@Today),
        CASE 
           WHEN MONTH(@Today) BETWEEN 1 AND 3 THEN 'Q1'
           WHEN MONTH(@Today) BETWEEN 4 AND 6 THEN 'Q2'
           WHEN MONTH(@Today) BETWEEN 7 AND 9 THEN 'Q3'
           ELSE 'Q4'
        END
    );
END

DECLARE @SnapshotTimeID INT;
SELECT TOP 1 @SnapshotTimeID = TimeID FROM dbo.DimTime WHERE FullDate = @Today;
PRINT N'✅ تم إنشاء TimeID: ' + CAST(@SnapshotTimeID AS NVARCHAR(10));
GO

-----------------------------
-- 6) FactSupplyChain
-----------------------------
PRINT N'💰 إدخال FactSupplyChain...';

DECLARE @TimeID INT;
SELECT TOP 1 @TimeID = TimeID FROM dbo.DimTime ORDER BY TimeID;

INSERT INTO dbo.FactSupplyChain (
    ProductID, SupplierID, CustomerID, ShippingID, TimeID,
    Availability, StockLevels, ProductsSold, Revenue, OrderQuantity,
    ManufacturingCosts, ShippingCost
)
SELECT
    p.ProductID,
    s.SupplierID,
    c.CustomerID,
    sh.ShippingID,
    @TimeID,
    sc.Availability,
    sc.StockLevels,
    sc.ProductsSold,
    sc.Revenue,
    sc.OrderQuantity,
    sc.ManufacturingCosts,
    sc.ShippingCosts
FROM dbo.SupplyChainAnalysis AS sc
JOIN dbo.DimProducts  AS p  ON sc.SKU                  = p.SKU
JOIN dbo.DimSuppliers AS s  ON sc.SupplierName         = s.SupplierName
                            AND sc.Location            = s.Location
JOIN dbo.DimCustomers AS c  ON sc.CustomerDemographics = c.CustomerDemographics
JOIN dbo.DimShipping  AS sh ON sc.ShippingCarrier      = sh.ShippingCarrier;

PRINT N'✅ عدد الصفوف المدخلة في FactSupplyChain: ' + CAST(@@ROWCOUNT AS NVARCHAR(10));
GO

PRINT N'🎉 اكتمل إدخال جميع البيانات في الـ DWH.';
GO



/* =========================================================
   FILE 03: Verification & Basic Analytics
   ========================================================= */

USE [supply chain];
GO

PRINT N'🔍 التحقق من عدد الصفوف...';

SELECT 
    N'DimProducts'     AS الجدول, COUNT(*) AS عدد_الصفوف FROM dbo.DimProducts
UNION ALL
SELECT 
    N'DimSuppliers',   COUNT(*) FROM dbo.DimSuppliers
UNION ALL
SELECT 
    N'DimCustomers',   COUNT(*) FROM dbo.DimCustomers
UNION ALL
SELECT 
    N'DimShipping',    COUNT(*) FROM dbo.DimShipping
UNION ALL
SELECT 
    N'DimTime',        COUNT(*) FROM dbo.DimTime
UNION ALL
SELECT 
    N'FactSupplyChain',COUNT(*) FROM dbo.FactSupplyChain;
GO

PRINT N'👀 عينة من جدول الحقائق مع الأبعاد...';

SELECT TOP 10
    f.FactID,
    p.SKU,
    p.ProductType,
    s.SupplierName,
    s.Location,
    c.CustomerDemographics,
    sh.ShippingCarrier,
    f.ProductsSold,
    f.Revenue,
    f.TotalCost,
    f.Profit
FROM dbo.FactSupplyChain f
JOIN dbo.DimProducts  p  ON f.ProductID  = p.ProductID
JOIN dbo.DimSuppliers s  ON f.SupplierID = s.SupplierID
JOIN dbo.DimCustomers c  ON f.CustomerID = c.CustomerID
JOIN dbo.DimShipping  sh ON f.ShippingID = sh.ShippingID
ORDER BY f.Profit DESC;
GO

PRINT N'📈 تحليل الربحية حسب نوع المنتج...';

SELECT 
    p.ProductType           AS نوع_المنتج,
    COUNT(f.FactID)         AS عدد_المعاملات,
    SUM(f.ProductsSold)     AS إجمالي_المبيعات,
    SUM(f.Revenue)          AS إجمالي_الإيرادات,
    SUM(f.Profit)           AS إجمالي_الربح,
    AVG(f.Profit)           AS متوسط_الربح_للمعاملة,
    AVG(p.DefectRate)       AS متوسط_معدل_العيوب
FROM dbo.FactSupplyChain f
JOIN dbo.DimProducts     p ON f.ProductID = p.ProductID
GROUP BY p.ProductType
ORDER BY إجمالي_الربح DESC;
GO

PRINT N'📈 تحليل أداء الموردين...';

SELECT
    s.SupplierName          AS اسم_المورد,
    s.Location              AS الموقع,
    COUNT(f.FactID)         AS عدد_الصفقات,
    SUM(f.Revenue)          AS إجمالي_الإيرادات,
    SUM(f.Profit)           AS إجمالي_الربح,
    AVG(f.Profit)           AS متوسط_الربح_للمعاملة,
    AVG(p.DefectRate)       AS متوسط_معدل_العيوب
FROM dbo.FactSupplyChain f
JOIN dbo.DimSuppliers    s ON f.SupplierID = s.SupplierID
JOIN dbo.DimProducts     p ON f.ProductID  = p.ProductID
GROUP BY s.SupplierName, s.Location
ORDER BY إجمالي_الربح DESC;
GO

PRINT N'📈 تحليل كفاءة الشحن...';

SELECT
    sh.ShippingCarrier          AS شركة_الشحن,
    COUNT(f.FactID)             AS عدد_الشحنات,
    AVG(f.ShippingCost)         AS متوسط_تكلفة_الشحن_الفعلية,
    AVG(sh.AverageShippingCost) AS متوسط_تكلفة_الشحن_المخططة,
    SUM(f.Profit)               AS إجمالي_الربح
FROM dbo.FactSupplyChain f
JOIN dbo.DimShipping     sh ON f.ShippingID = sh.ShippingID
GROUP BY sh.ShippingCarrier
ORDER BY إجمالي_الربح DESC;
GO

PRINT N'✅ النظام تم التحقق منه وهو جاهز للاستخدام 👌';
GO



-- اختبارات إضافية
PRINT N'🔍 اختبارات إضافية...';
SELECT COUNT(*) AS 'عدد الصفوف في supply_chain_data' FROM dbo.supply_chain_data;
SELECT TOP 5 * FROM dbo.SupplyChainAnalysis;
GO

--اختبار أي Orphan Records (لازم يرجع 0)
PRINT N'🔍 اختبار Orphan Records...';

-- Products
SELECT COUNT(*) AS OrphansProducts
FROM dbo.FactSupplyChain f
LEFT JOIN dbo.DimProducts d ON f.ProductID = d.ProductID
WHERE d.ProductID IS NULL;

-- Suppliers
SELECT COUNT(*) AS OrphansSuppliers
FROM dbo.FactSupplyChain f
LEFT JOIN dbo.DimSuppliers d ON f.SupplierID = d.SupplierID
WHERE d.SupplierID IS NULL;

-- Customers
SELECT COUNT(*) AS OrphansCustomers
FROM dbo.FactSupplyChain f
LEFT JOIN dbo.DimCustomers d ON f.CustomerID = d.CustomerID
WHERE d.CustomerID IS NULL;

-- Shipping
SELECT COUNT(*) AS OrphansShipping
FROM dbo.FactSupplyChain f
LEFT JOIN dbo.DimShipping d ON f.ShippingID = d.ShippingID
WHERE d.ShippingID IS NULL;

-- Time
SELECT COUNT(*) AS OrphansTime
FROM dbo.FactSupplyChain f
LEFT JOIN dbo.DimTime d ON f.TimeID = d.TimeID
WHERE d.TimeID IS NULL;
GO

PRINT N'🎉 الكود اكتمل بنجاح!';
GO