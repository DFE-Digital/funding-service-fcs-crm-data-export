DROP TABLE IF EXISTS [dbo].[EntityMetadata];
GO
DROP TABLE IF EXISTS [dbo].[CRMEntityAttributeMetadata];
GO
DROP TABLE IF EXISTS [dbo].[CRMDataExportSyncHistory];
GO
DROP PROCEDURE IF EXISTS [dbo].[GetStatusOfAllEntitiesForEntityData]
GO

DROP INDEX IF EXISTS IX_sfa_contractdeliverableperiod_modifiedon
ON dbo.sfa_contractdeliverableperiod;
GO

DROP INDEX IF EXISTS IX_sfa_subnominalaggregation_modifiedon
ON sales.sfa_subnominalaggregation;
GO

DROP INDEX IF EXISTS IX_sfa_contractdeliverable_modifiedon
ON sfa_contractdeliverable;
GO