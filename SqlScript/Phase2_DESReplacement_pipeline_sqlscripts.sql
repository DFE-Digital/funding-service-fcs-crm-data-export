/****** Object:  Table [dbo].[EntityMetadata]    Script Date: 01/02/2023 16:48:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
DROP TABLE IF EXISTS [dbo].[EntityMetadata];

CREATE TABLE [dbo].[EntityMetadata](
	[SourcetEntityId] [uniqueidentifier] NOT NULL,
	[EntityName] [varchar](80) NOT NULL,
	[EntitySetName] [varchar](80) NOT NULL,
	[PrimaryIdAttribute] [varchar](80) NOT NULL,
	[MetadataId] [uniqueidentifier] NOT NULL,
	[InUse] [bit] NOT NULL,
	[DeltaMarker] [nvarchar](255) NULL,
	[DeltaMarkerAttribute] [nvarchar](64) NULL,
	[Query] [nvarchar](max) NULL,
	[Mapping] [nvarchar](max) NULL,
	[IsDeltaLoad] [bit] NULL,
	[Version] [bigint] NULL,
	[Timestamp] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SourcetEntityId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[EntityMetadata] ADD  DEFAULT (newid()) FOR [SourcetEntityId]
GO

ALTER TABLE [dbo].[EntityMetadata] ADD  DEFAULT ((1)) FOR [InUse]
GO

ALTER TABLE [dbo].[EntityMetadata] ADD  DEFAULT ((1)) FOR [IsDeltaLoad]
GO

/****** Object:  Table [dbo].[CRMEntityAttributeMetadata]    Script Date: 01/02/2023 16:49:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [dbo].[CRMEntityAttributeMetadata];

CREATE TABLE [dbo].[CRMEntityAttributeMetadata](
	[AttributeMetadataId] [uniqueidentifier] NOT NULL,
	[AttributeName] [varchar](80) NULL,
	[EntityName] [varchar](80) NULL,
	[AttributeType] [varchar](80) NULL,
	[AttributeTypeName] [varchar](80) NULL,
	[Mapping] [nvarchar](max) NULL,
	[AdditionalcolumnsMapping] [nvarchar](max) NULL,
	[IsValidOdataAttribute] [bit] NULL,
	[Precision] [int] NULL,
	[MetadataId] [uniqueidentifier] NULL,
	[IsPrimaryId] [bit] NULL,
	[AttributeTypeCode] [int] NULL,
	[MaxLength] [int] NULL,
	[Targets] [nvarchar](max) NULL,
	[InUse] [bit] NULL,
	[IsValidForAdvancedFind] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[AttributeMetadataId] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[CRMEntityAttributeMetadata] ADD  DEFAULT (newid()) FOR [AttributeMetadataId]
GO

ALTER TABLE [dbo].[CRMEntityAttributeMetadata] ADD  DEFAULT ((1)) FOR [InUse]
GO


/****** Object:  Table [dbo].[CRMDataExportSyncHistory]    Script Date: 01/02/2023 16:50:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

DROP TABLE IF EXISTS [dbo].[CRMDataExportSyncHistory];

CREATE TABLE [dbo].[CRMDataExportSyncHistory](
	[Id] [uniqueidentifier] NOT NULL,
	[EntityName] [varchar](80) NOT NULL,
	[DeltaMarker] [datetime] NOT NULL,
	[LastRunOn] [datetime] NOT NULL,
	[Status] [tinyint] NOT NULL,
	[SourcetEntityId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[CRMDataExportSyncHistory] ADD  DEFAULT (newid()) FOR [Id]
GO

ALTER TABLE [dbo].[CRMDataExportSyncHistory]  WITH CHECK ADD  CONSTRAINT [ADFPipelineConfiguration_CRMDataExportSyncHistoryPK] FOREIGN KEY([SourcetEntityId])
REFERENCES [dbo].[EntityMetadata] ([SourcetEntityId])
GO

ALTER TABLE [dbo].[CRMDataExportSyncHistory] CHECK CONSTRAINT [ADFPipelineConfiguration_CRMDataExportSyncHistoryPK]
GO


/****** Object:  StoredProcedure [dbo].[GetStatusOfAllEntitiesForEntityData]    Script Date: 01/02/2023 17:08:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-------------------------ONE TIME SCRIPT-----------------------------------------------------------------------------

UPDATE [dbo].EntityMetadata 
set DeltaMarker = '2023-01-16T00:00:00Z'
where EntityName IN('sfa_contract','sfa_contractallocation','sfa_fundingstreamperiod','sfa_status','sfa_contractdeliverable',
                    'sfa_subnominalaggregation','sfa_unitofprocurement','sfa_fundingtype','sfa_contractdeliverableperiod','account','sfa_fundingstreamperioddeliverable')

GO
---------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE IF EXISTS [dbo].[GetStatusOfAllEntitiesForEntityData]
GO

CREATE PROCEDURE [dbo].[GetStatusOfAllEntitiesForEntityData] 
@IsCopyAllEntity bit,  --If all entities copy activty is succeeded then 1 else 0 
@Pipeline varchar(100) -- pipeline Name
AS
	BEGIN
		 SET NOCOUNT ON  
         SET transaction isolation level read committed 

		DECLARE @strResult   varchar(200)
		DECLARE @strPipelineMessage   varchar(200)
		DECLARE @LastPipelineRun datetime

		-- Get last executed timestamp of pipeline, so it will use to query table list copy status (Success/ fail) for currently running pipeline
		DECLARE @LastExtractDate DATETIME = (
         SELECT TOP 1 createddate FROM ADFPipelineAudit where pipeline  = @Pipeline and  ActivityName='PipelineStatus' order by createddate desc)

		  if (@LastExtractDate is null)
		   BEGIN
				SET @LastExtractDate = CAST( '2022-01-01 00:00:00.000' AS datetime)
		   END 

		CREATE TABLE #tmpSelectedTbl(SourceEntityname nvarchar(max));

		IF( @IsCopyAllEntity=0) 
			BEGIN
				SET @strPipelineMessage= 'Pipeline *'+@Pipeline+'* Is Failed, entity copy status as follows -'
			END

		Insert INTO #tmpSelectedTbl(SourceEntityname) SELECT @strPipelineMessage;

		-- using last execution timestamp of pipeline get all entity which processed in current pipeline execution with copy status (Success/ Fail)
		WITH cte AS
        (
           SELECT
            Entityname +' - '+
            case Status
            when 0 then 'Fail'
            When 1 then 'Success'
            end as result,
            ROW_NUMBER() OVER (PARTITION BY Entityname ORDER BY DeltaMarker DESC) AS rn
		   FROM CRMDataExportSyncHistory WHERE DeltaMarker > @LastExtractDate
        )

	    Insert INTO #tmpSelectedTbl(SourceEntityname)
		SELECT result
		FROM cte
		WHERE rn = 1

		IF( @IsCopyAllEntity=1)
			BEGIN
				SET @strResult = 'Pipeline *'+@Pipeline+'* Is succeeded'
			END
		ELSE
			BEGIN
					-- format output list of copy activty completed table each table display on new line 
					IF((SELECT count(*) FROM #tmpSelectedTbl)>1)
					BEGIN
						SET  @strResult =  (SELECT STRING_AGG(SourceEntityname, CHAR(10)) AS 'text' FROM #tmpSelectedTbl )
					END;
				ELSE
					BEGIN
						SET  @strResult = 'Pipeline *'+@Pipeline+'* Is Failed, '+ +'No run found'
					END;
			END
		
		
		SELECT @strResult as 'text'  -- this is importent Slack web api Body needs  'text' as key in key value pair ex - {text : sfa_contract - Fail}
	    

	END
GO
