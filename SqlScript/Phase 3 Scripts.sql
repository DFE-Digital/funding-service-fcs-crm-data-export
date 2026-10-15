/****** Object: Table [dbo].[audit] Script Date: 12/05/2023 11:09:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[audit](
[objecttypecode] [nvarchar](max) NULL,
[_objectid_value] [uniqueidentifier] NULL,
[action] [int] NULL,
[operation] [int] NULL,
[createdon] [datetime2](7) NULL,
[auditid] [uniqueidentifier] NULL,
[DateInserted] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[audit] ADD DEFAULT (getdate()) FOR [DateInserted]
GO
/****** Object: StoredProcedure 
[dbo].[GetDeleteRecordGuidsFromAuditAndDeleteTheRecordsFromRespectiveTables] Script 
Date: 12/05/2023 11:12:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE
[dbo].[GetDeleteRecordGuidsFromAuditAndDeleteTheRecordsFromRespectiveTables]
AS
BEGIN
DECLARE @DeltaMarker DATETIME = (select DeltaMarker from EntityMetadata where
EntityName='audit')
--DECLARE @DeltaMarker DATETIME =CAST('2023-03-13 13:14:33.0000000' AS DATETIME2)
PRINT @DeltaMarker
DELETE FROM sfa_contract where id in
(select _objectid_value from audit where createdon>=@deltamarker and
objecttypecode='sfa_contract')
DELETE FROM sfa_unitofprocurement where id in
(select _objectid_value from audit where createdon>=@deltamarker and
objecttypecode='sfa_unitofprocurement')
DELETE FROM account where id in
(select _objectid_value from audit where createdon>=@deltamarker and
objecttypecode='account')
DELETE FROM sfa_contractallocation where id in
(select _objectid_value from audit where createdon>=@deltamarker and
objecttypecode='sfa_contractallocation')
DELETE FROM sfa_status where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_status')
DELETE FROM sfa_subnominalaggregation where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_subnominalaggregation')
DELETE FROM sfa_contractdeliverable where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_contractdeliverable')
DELETE FROM sfa_fundingstreamperiod where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_fundingstreamperiod')
DELETE FROM sfa_contractdeliverableperiod where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_contractdeliverableperiod')
DELETE FROM sfa_fundingtype where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_fundingtype')
DELETE FROM sfa_fundingstreamperioddeliverable where id in
(select _objectid_value from audit where createdon>=@deltamarker and 
objecttypecode='sfa_fundingstreamperioddeliverable')
END
GO