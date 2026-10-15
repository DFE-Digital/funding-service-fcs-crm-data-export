--Execute one time script to add NONCLUSTERED Index on (sfa_contractdeliverableperiod, sfa_contractdeliverable, sfa_subnominalaggregation) This script will take some time for execution 

IF EXISTS (SELECT name FROM sys.indexes  
            WHERE name = N'IX_sfa_contractdeliverableperiod_modifiedon')   
    DROP INDEX IX_sfa_contractdeliverableperiod_modifiedon ON dbo.sfa_contractdeliverableperiod;   
GO  

CREATE NONCLUSTERED INDEX IX_sfa_contractdeliverableperiod_modifiedon   
    ON dbo.sfa_contractdeliverableperiod (modifiedon DESC);   
GO  

ALTER INDEX IX_sfa_contractdeliverableperiod_modifiedon ON dbo.sfa_contractdeliverableperiod REBUILD ;


IF EXISTS (SELECT name FROM sys.indexes  
            WHERE name = N'IX_sfa_subnominalaggregation_modifiedon')   
    DROP INDEX IX_sfa_subnominalaggregation_modifiedon ON dbo.sfa_subnominalaggregation;   
GO  

CREATE NONCLUSTERED INDEX IX_sfa_subnominalaggregation_modifiedon   
    ON dbo.sfa_subnominalaggregation (modifiedon DESC);   
GO  

ALTER INDEX IX_sfa_subnominalaggregation_modifiedon ON dbo.sfa_subnominalaggregation REBUILD ;


IF EXISTS (SELECT name FROM sys.indexes  
            WHERE name = N'IX_sfa_contractdeliverable_modifiedon')   
    DROP INDEX IX_sfa_contractdeliverable_modifiedon ON dbo.sfa_contractdeliverable;   
GO  

CREATE NONCLUSTERED INDEX IX_sfa_contractdeliverable_modifiedon   
    ON dbo.sfa_contractdeliverable (modifiedon DESC);   
GO  

ALTER INDEX IX_sfa_contractdeliverable_modifiedon ON dbo.sfa_contractdeliverable REBUILD ;


