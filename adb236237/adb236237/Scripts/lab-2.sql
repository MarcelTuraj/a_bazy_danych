-- =============================================
-- Marcel
-- Turaj
-- 236237
-- =============================================
-- Zadanie 1
-- =============================================
-- ProductVendor to tabela ³¹cz¹ca wiêc dodajemy dwupolowy klucz podstawowy

-- Indeks dla ParentProductID dodajemy by wyszukaæ elementy potrzebne do budowy produktu nadrzêdnego (roweru)

-- Indeks dla CompontentProductID tworzymy w celu wyszukania w jakich produktach u¿ywany jest konkretny komponent

-- Indeksy dla VendorID i ProductID w PriceHistory tworzymy dla analizy historii cen dla produktu i dostawcy po ID

-- Indeks pod ShipmentTrackingEvents dodajemy w celu œledzenia zdarzeñ odnoœnie zamówieñ


ALTER TABLE SalesLT.ProductVendor ADD CONSTRAINT PK_ProductVendor PRIMARY KEY (ProductID,VendorID)
GO

CREATE INDEX IX_BOM_PARENT on SalesLT.ProductBOM (ParentProductID);
GO

CREATE INDEX IX_BOM_COMPONENT on SalesLT.ProductBOM (ComponentProductID);
GO

CREATE INDEX IX_PriceHistory on SalesLT.VendorPriceHistory (VendorID, ProductID)
GO

CREATE INDEX IX_Tracking on SalesLT.ShipmentTrackingEvents (SalesOrderID)
GO

-- =============================================
-- Zadanie 2
-- =============================================

CREATE INDEX IX_Vendor_Active on SalesLT.Vendor (Name, ActiveFlag)
WHERE ActiveFlag = 1;
GO

-- =============================================
-- Zadanie 3
-- =============================================

-- Indeks pokrywaj¹cy --> analiza dostawcy w oparciu o standardow¹ cenê produktu i œredni czas dostawy

CREATE INDEX IX_ProductVendor_ProductCover
ON SalesLT.ProductVendor(ProductID)
INCLUDE (StandardPrice, AverageLeadTime);

SELECT
    StandardPrice,
    AverageLeadTime
FROM SalesLT.ProductVendor
WHERE ProductID = 680;
GO

-- Indeks filtrowany do wyszukiwania dostawców z najwy¿sz¹ ocen¹ kredytow¹ (credit rating)

CREATE INDEX IX_Vendor_TopCredit
ON SalesLT.Vendor(Name)
WHERE CreditRating = 5;
GO

SELECT Name
FROM SalesLT.Vendor
WHERE CreditRating = 5;
GO

-- Indeks umo¿liwiaj¹cy wyszukiwanie zdarzeñ logistycznych w oparciu o konkretn¹ lokacjê (logika nieco inna ni¿ w zad 1)

CREATE INDEX IX_Tracking_Location
ON SalesLT.ShipmentTrackingEvents(Location);
GO

SELECT *
FROM SalesLT.ShipmentTrackingEvents
WHERE Location = 'Magazyn Centralny';
GO

-- =============================================
-- Zadanie 4
-- =============================================

ALTER INDEX IX_PriceHistory on SalesLT.VendorPriceHistory 
REBUILD WITH (FILLFACTOR = 25);
GO


-- =============================================
-- Zadanie 5
-- =============================================

-- Tabela i indeksy dotycz¹ce wystawianych ocen (recenzji) dla dostawców produktów 
CREATE TABLE SalesLT.VendorReview
(
    ReviewID INT NOT NULL,
    VendorID INT NOT NULL,
    ProductID INT NOT NULL,
    Rating TINYINT,
    ReviewDate DATETIME,
    Comment NVARCHAR(200),

    CONSTRAINT FK_VendorReview_Vendor
        FOREIGN KEY (VendorID)
        REFERENCES SalesLT.Vendor(VendorID),

    CONSTRAINT FK_VendorReview_Product
        FOREIGN KEY (ProductID)
        REFERENCES SalesLT.Product(ProductID)
);
GO
-- Indeks klastrowy
CREATE CLUSTERED INDEX IX_VendorReview_Clustered
ON SalesLT.VendorReview(ReviewID);
GO
-- Indeks pokrywaj¹cy
CREATE INDEX IX_VendorReview_Vendor
ON SalesLT.VendorReview(VendorID)
INCLUDE (Rating, ReviewDate);
GO

-- Indeks filtrowany
CREATE INDEX IX_VendorReview_Best
ON SalesLT.VendorReview(ProductID)
WHERE Rating = 5;
GO

