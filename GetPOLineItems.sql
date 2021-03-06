USE [Amazon]
GO
/****** Object:  StoredProcedure [dbo].[GetPOLineItems]    Script Date: 7/20/2016 2:46:31 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[GetPOLineItems]
	-- Add the parameters for the stored procedure here
	@PONumber NVARCHAR(15),
	@SizeStandard NVARCHAR(2) = 'US'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT SKU + ' ' + COALESCE([Row],'') AS Item, Size, Quantity, SKU, [Segment] into #temp
	FROM 
		(SELECT [Ordered_01]
			,[Ordered_02]
			,[Ordered_03]
			,[Ordered_04]
			,[Ordered_05]
			,[Ordered_06]
			,[Ordered_07]
			,[Ordered_08]
			,[Ordered_09]
			,[Ordered_10]
			,[Ordered_11]
			,[Ordered_12]
			,[Ordered_13]
			,[Ordered_14]
			,[Ordered_15]
			,[Ordered_16]
			,[Ordered_17]
			,[Ordered_18]
			,SKU
			,[Row]
			,[Segment]
		FROM [Purchase_Detail] where [PO Number] = @PONumber) p 				
	UNPIVOT
		(Quantity FOR Size IN 
			([Ordered_01]
			,[Ordered_02]
			,[Ordered_03]
			,[Ordered_04]
			,[Ordered_05]
			,[Ordered_06]
			,[Ordered_07]
			,[Ordered_08]
			,[Ordered_09]
			,[Ordered_10]
			,[Ordered_11]
			,[Ordered_12]
			,[Ordered_13]
			,[Ordered_14]
			,[Ordered_15]
			,[Ordered_16]
			,[Ordered_17]
			,[Ordered_18])
	)AS unpvt;

	--SELECT * FROM #temp WHERE Item is NULL;


	DELETE ShippingPlanLineItem;

	-- Use the correct Size Standard
	IF @SizeStandard = 'EU'
		BEGIN

			INSERT INTO dbo.ShippingPlanLineItem
			(
				SKU,
				Quantity
			)	
			SELECT RTRIM(LTRIM(Item)) + ' ' +
			CASE 
				WHEN Size = 'Ordered_01' and [Segment] = 1 then '35'	
				WHEN Size = 'Ordered_02' and [Segment] = 1 then '36'	
				WHEN Size = 'Ordered_03' and [Segment] = 1 then '37'	
				WHEN Size = 'Ordered_04' and [Segment] = 1 then '38'	
				WHEN Size = 'Ordered_05' and [Segment] = 1 then '39'	
				WHEN Size = 'Ordered_06' and [Segment] = 1 then '40'	
				WHEN Size = 'Ordered_07' and [Segment] = 1 then '41'	
				WHEN Size = 'Ordered_08' and [Segment] = 1 then '42'	
				WHEN Size = 'Ordered_09' and [Segment] = 1 then '43'	
				WHEN Size = 'Ordered_10' and [Segment] = 1 then '44'	
				WHEN Size = 'Ordered_11' and [Segment] = 1 then '45'	
				WHEN Size = 'Ordered_12' and [Segment] = 1 then '46'	
				WHEN Size = 'Ordered_13' and [Segment] = 1 then '47'	
				WHEN Size = 'Ordered_14' and [Segment] = 1 then '48'
				ELSE '**INVALID SIZE**'	
			END AS LineItem, Quantity
			FROM #temp WHERE Quantity > 0 

		END
	ELSE
		BEGIN
			INSERT INTO dbo.ShippingPlanLineItem
			(
				SKU,
				Quantity
			)	
			SELECT RTRIM(LTRIM(Item)) + ' ' +
			CASE 
				WHEN Size = 'Ordered_01' and [Segment] = 1 then '4'	
				WHEN Size = 'Ordered_02' and [Segment] = 1 then '4.5'	
				WHEN Size = 'Ordered_03' and [Segment] = 1 then '5'	
				WHEN Size = 'Ordered_04' and [Segment] = 1 then '5.5'	
				WHEN Size = 'Ordered_05' and [Segment] = 1 then '6'	
				WHEN Size = 'Ordered_06' and [Segment] = 1 then '6.5'	
				WHEN Size = 'Ordered_07' and [Segment] = 1 then '7'	
				WHEN Size = 'Ordered_08' and [Segment] = 1 then '7.5'	
				WHEN Size = 'Ordered_09' and [Segment] = 1 then '8'	
				WHEN Size = 'Ordered_10' and [Segment] = 1 then '8.5'	
				WHEN Size = 'Ordered_11' and [Segment] = 1 then '9'	
				WHEN Size = 'Ordered_12' and [Segment] = 1 then '9.5'	
				WHEN Size = 'Ordered_13' and [Segment] = 1 then '10'	
				WHEN Size = 'Ordered_14' and [Segment] = 1 then '10.5'	
				WHEN Size = 'Ordered_15' and [Segment] = 1 then '11'	
				WHEN Size = 'Ordered_16' and [Segment] = 1 then '11.5'	
				WHEN Size = 'Ordered_17' and [Segment] = 1 then '12'	
				WHEN Size = 'Ordered_18' and [Segment] = 1 then '13'	
				WHEN Size = 'Ordered_01' and [Segment] = 2 then '14'	
				WHEN Size = 'Ordered_02' and [Segment] = 2 then '15'	
				WHEN Size = 'Ordered_03' and [Segment] = 2 then '16'	
				WHEN Size = 'Ordered_04' and [Segment] = 2 then '17'
				ELSE '**INVALID SIZE**'		
			END AS LineItem, Quantity
			FROM #temp WHERE Quantity > 0
		END

	DROP TABLE #temp;

END
