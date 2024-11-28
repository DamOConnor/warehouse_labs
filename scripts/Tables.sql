CREATE TABLE Trips 
(
	[vendorID] varchar(5),	
	[tpepPickupDateTime] datetime2(6),
	[tpepDropoffDateTime] datetime2(6),
	[passengerCount] int,
	[tripDistance] float,
	[puLocationId] varchar(5),
	[doLocationId] varchar(5),
	[startLon] float,
	[startLat] float,
	[endLon] float,
	[endLat] float,
	[rateCodeId] int,
	[storeAndFwdFlag] varchar(5),
	[paymentType] varchar(5),
	[fareAmount] float,
	[extra] float,
	[mtaTax] float,
	[improvementSurcharge] varchar(10),
	[tipAmount] float,
	[tollsAmount] float,
	[totalAmount] float
)

COPY INTO [dbo].[Trips]
FROM 
'https://azureopendatastorage.blob.core.windows.net/nyctlc/yellow/puYear=2016/puMonth=*/*.parquet',
'https://azureopendatastorage.blob.core.windows.net/nyctlc/yellow/puYear=2017/puMonth=*/*.parquet',
'https://azureopendatastorage.blob.core.windows.net/nyctlc/yellow/puYear=2018/puMonth=*/*.parquet'
WITH
(
    FILE_TYPE = 'PARQUET'
)


--Cross-datawarehouse-lakehouse query pattern
--Also highlight in this query, there will be auto-statistics that will be created over the columns being aggregated and the join columns
SELECT TOP 10 dl.[LocationID]
FROM [dbo].[Trips] -- table in dw
INNER JOIN 
--delta table in lakehouse, imagine this table in bronze zone (where it can still be queried in dw for early discovery of the insight)
--this is the CSV file dimLocation which you loaded and saved as dimLocation_TaxiZone. Replace with your own lakehouse name
[mylakehouse01].[dbo].[dimlocation_taxizone] dl 
ON paymentType = dl.[LocationID]