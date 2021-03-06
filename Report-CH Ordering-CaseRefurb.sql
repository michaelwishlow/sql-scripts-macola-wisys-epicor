--Created:	1/9/14	     By:	BG
--Last Updated:	3/13/14	 By:	BG
--Purpose: Case refurb version of china ordering report [BG_Daily_CH_Order_Report]
--Last Change: 1) Added stock order qty, avg qps ytd, and sls count columns
--             2) Added stock order qty calculation (QOH+QSTK+QOO-QOA-(ESS/WMF/QPROJ) 

USE [001]
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[BG_Daily_CH_Order_Report_CR] AS
SELECT TOP (100) PERCENT '___' AS LN, 
		Z_IMINVLOC.prod_cat AS Cat,  
		Z_IMINVLOC.item_no, IMITMIDX_SQL.item_desc_1, IMITMIDX_SQL.item_desc_2, 
		CASE WHEN (IMITMIDX_SQL.extra_1) IS NULL THEN '' ELSE IMITMIDX_SQL.extra_1 END AS Parent,
		IMITMIDX_SQL.extra_6 AS [CH-US],
        CAST(Z_IMINVLOC.qty_on_ord AS INT) AS QOO, 
        CAST(Z_IMINVLOC.qty_on_hand AS Int) AS QOH, 
        CAST(QC.[QOH CHECK] AS INT) AS [QOH CHK],
        IMITMIDX_SQL.uom, 
        IMITMIDX_SQL.item_note_3 AS QPS,
        '___' AS AQOH, 
        CAST(Z_IMINVLOC.frz_qty AS INT) AS FQTY, 
        --dbo.Z_IMINVLOC_QALL.qty_allocated AS QALL_ALL, 
        CASE WHEN proj.qty_proj > 0 THEN CAST((dbo.Z_IMINVLOC_QALL.qty_allocated - Proj.qty_proj) AS Int) 
			 ELSE CAST(Z_IMINVLOC_QALL.qty_allocated AS Int) 
        END AS QALL, 
        CASE WHEN proj.qty_proj > 0 THEN CAST(proj.qty_proj AS INT) 
			 ELSE '0' 
		END AS QPROJ, 
		IMITMIDX_SQL.item_note_4 AS ESS,  
        CASE WHEN Z_IMINVLOC.prior_year_usage IS NULL THEN 0
             ELSE CAST(ROUND(Z_IMINVLOC.prior_year_usage / 12, 0) AS INT) 
        END AS PMNTH, 
			
        CASE WHEN Z_IMINVLOC_USAGE.usage_ytd IS NULL THEN 0
			 ELSE CEILING(dbo.Z_IMINVLOC_USAGE.usage_ytd / (DATEDIFF(day, CONVERT(datetime, 
               '01/01/2013', 103), GETDATE()) / 30.5)) 
        END AS CMNTH, 
        --CAST(Z_IMINVLOC.qty_on_hand - dbo.Z_IMINVLOC_QALL.qty_allocated AS Int) AS [QOH-QOA], 
        CASE WHEN z_iminvloc_usage.usage_ytd > 0 
			 THEN CAST(((qty_on_hand + qty_on_ord) / CEILING((z_iminvloc_usage.usage_ytd / (DATEDIFF(day,CONVERT(datetime, '01/01/2013', 103), GETDATE()) / 30.5)))) AS money) 
		ELSE 0 END AS MOI,  
        CASE  WHEN (imitmidx_sql.extra_1 = 'P' AND imitmidx_sql.extra_6 != 'CH-US' AND imitmidx_sql.extra_1 IS NOT NULL)
				THEN ''							
				--If there is an ESS and >= QPROJ then use the ESS and allocations w/o projections
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand > 0)
						 AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0)) < 0
					THEN 'NC-ESS'
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand <= 0)	
						 AND (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0)) < 0
					THEN 'NC-ESS'
					--No projections section, required to avoid nulls in the calculation--				
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand >= 0)
						 AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj), 0)) < 0
					THEN 'NC-ESS'
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand <= 0)	
						 AND (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj), 0)) < 0
					THEN 'NC-ESS'				
				--If there is a qty projected and an ESS and it is >= ESS or there is no ESS, then use allocations w/ projections
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand > 0)
					      AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL)
					      AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0)) < 0
					THEN 'NC-PROJ'
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand <= 0) 
						  AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL) 
						  AND (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0)) < 0
					THEN 'NC-PROJ'
			   --If there is a qty projected and an ESS and if qty projected is < then ESS, then use ESS and allocations w/o projections
					WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand >= 0) AND Proj.qty_proj >= 0
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
						 AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) < 0
				    THEN 'NC-ESS'
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand <= 0) AND Proj.qty_proj >= 0 
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
						 AND (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) < 0
				    THEN 'NC-ESS'
			   --If there is no qty projected but an ESS, then use ESS and normal allocations                                
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND Proj.qty_proj IS NULL
						 AND (Z_IMINVLOC.qty_on_hand >= 0) 
						 AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0)) < 0
				    THEN 'NC-ESS'
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND Proj.qty_proj IS NULL
						 AND (Z_IMINVLOC.qty_on_hand < 0) 
						 AND (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0))  < 0
				    THEN 'NC-ESS'
			   --If there is no ESS but an qty projected, then use allocations w/ projections
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL)
						 AND Proj.qty_proj >= 0	 AND (Z_IMINVLOC.qty_on_hand >= 0)
						 AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated), 0)) < 0  
				   THEN 'NC-PROJ'
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj >= 0 AND (Z_IMINVLOC.qty_on_hand < 0)  
						AND (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated), 0))	 < 0 
				   THEN 'NC-PROJ'
			  --If there is no ESS and no qty projected, then use none		
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand >= 0) 
						AND (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0)) < 0 
				   THEN 'NC'  
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand < 0) 
						AND (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0)) < 0
				  THEN  'NC'	            
         ELSE '' END AS [CHECK],  
          CASE  --If there is an ESS and it is >= QPROJ then use the ESS
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand > 0)
					THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0))
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand <= 0)					 
					THEN (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0))						
				--If there is a qty projected and an ESS and it is >= ESS or there is no ESS, then use allocations w/ projections
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand > 0)
					      AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL)
					THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand <= 0) 
						  AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL) 
					THEN (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))
			   --If there is a qty projected and an ESS and if qty projected is < then ESS, then use allocations w/o projections
					WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand >= 0) AND Proj.qty_proj >= 0
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
				    THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) 
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand <= 0) AND Proj.qty_proj >= 0 
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
				    THEN (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) 
			   --If there is no qty projected but an ESS, then use ESS and normal allocations                                
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND Proj.qty_proj IS NULL
						 AND (Z_IMINVLOC.qty_on_hand >= 0) 
				    THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0)) 
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand <= 0) 
				    THEN (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0)) 
			   --If there is no ESS but an qty projected, then use qty projected and allocations w/o projections
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						 AND Proj.qty_proj >= 0	 AND (Z_IMINVLOC.qty_on_hand >= 0) 
				   THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - Proj.qty_proj, 0))	
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj >= 0 AND (Z_IMINVLOC.qty_on_hand < 0)  
				   THEN (ROUND(Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - Proj.qty_proj, 0))				
			  --If there is no forecast and no ESS and no qty projected, then use none		
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand >= 0) 
				   THEN (ROUND(Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))     
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand < 0) 
				   THEN (ROUND(Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))	            
         ELSE 0 
         END AS [QOH+QOO-QOA-(ESS/WMF/QPROJ)],     
         CASE  				
			--If there is an ESS and it is >= QPROJ then use the ESS
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand > 0)
					THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0))
					WHEN imitmidx_Sql.item_note_4 >= 0
						 AND (imitmidx_Sql.item_note_4 >= Proj.qty_proj) 
						 AND (Z_IMINVLOC.qty_on_hand <= 0)					 
					THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated-Proj.qty_proj) - imitmidx_Sql.item_note_4, 0))						
				--If there is a qty projected and an ESS and it is >= ESS or there is no ESS, then use allocations w/ projections
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand > 0)
					      AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL)
					THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))
					WHEN (Proj.qty_proj >= 0) AND (Z_IMINVLOC.qty_on_hand <= 0) 
						  AND (Proj.qty_proj >= imitmidx_Sql.item_note_4 OR imitmidx_Sql.item_note_4 IS NULL) 
					THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))
			   --If there is a qty projected and an ESS and if qty projected is < then ESS, then use allocations w/o projections
					WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand >= 0) AND Proj.qty_proj >= 0
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
				    THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) 
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand <= 0) AND Proj.qty_proj >= 0 
						 AND Proj.qty_proj < imitmidx_Sql.item_note_4
				    THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - IMITMIDX_SQL.item_note_4, 0)) 
			   --If there is no qty projected but an ESS, then use ESS and normal allocations                                
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND Proj.qty_proj IS NULL
						 AND (Z_IMINVLOC.qty_on_hand >= 0) 
				    THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0)) 
				    WHEN (NOT (IMITMIDX_SQL.item_note_4 IS NULL)) AND (Z_IMINVLOC.qty_on_hand <= 0) 
				    THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated - IMITMIDX_SQL.item_note_4, 0)) 
			   --If there is no ESS but an qty projected, then use qty projected and allocations w/o projections
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						 AND Proj.qty_proj >= 0	 AND (Z_IMINVLOC.qty_on_hand >= 0) 
				   THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - Proj.qty_proj, 0))	
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj >= 0 AND (Z_IMINVLOC.qty_on_hand < 0)  
				   THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - (z_iminvloc_qall.qty_allocated - Proj.qty_proj) - Proj.qty_proj, 0))				
			  --If there is no forecast and no ESS and no qty projected, then use none		
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand >= 0) 
				   THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_hand + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))     
				   WHEN (IMITMIDX_SQL.item_note_4 IS NULL) 
						AND Proj.qty_proj IS NULL
						AND (Z_IMINVLOC.qty_on_hand < 0) 
				   THEN (ROUND(STOCK_ORDER.qty + Z_IMINVLOC.qty_on_ord - z_iminvloc_qall.qty_allocated, 0))	            
         ELSE 0 
         END AS [QOH+QSTK+QOO-QOA-(ESS/WMF/QPROJ)],    
        /*     
       CASE WHEN (NOT (imitmidx_sql.extra_1 = 'P') OR imitmidx_sql.extra_1 IS NULL OR  imitmidx_sql.extra_6 = 'CH-US') 
				AND (Z_IMINVLOC.qty_on_hand <= 0) 
				AND ((ROUND(Z_IMINVLOC.qty_on_ord - (3 * CEILING(dbo.Z_IMINVLOC_USAGE.usage_ytd / (DATEDIFF(day, CONVERT(datetime, '01/01/2013', 103), GETDATE()) / 30.5))), 0)) < 0) 
       THEN 'NC' 
       WHEN (NOT (imitmidx_sql.extra_1 = 'P') OR imitmidx_sql.extra_1 IS NULL OR imitmidx_sql.extra_6 = 'CH-US') 
			AND (Z_IMINVLOC.qty_on_hand > 0) 
			AND ((ROUND(Z_IMINVLOC.qty_on_ord - Z_IMINVLOC.qty_on_hand - (3 * CEILING(dbo.Z_IMINVLOC_USAGE.usage_ytd / (DATEDIFF(day, CONVERT(datetime, '01/01/2013', 103), GETDATE()) / 30.5))), 0)) < 0) 
	   THEN 'NC' 
       ELSE '' END AS [CHECK 90], 
       */
       /*
       CASE WHEN (Z_IMINVLOC.qty_on_hand > 0) AND NOT (Z_IMINVLOC_USAGE.usage_ytd IS NULL)
			THEN (ROUND(Z_IMINVLOC.qty_on_ord + Z_IMINVLOC.qty_on_hand - (3 * CEILING(dbo.Z_IMINVLOC_USAGE.usage_ytd / (DATEDIFF(day, CONVERT(datetime, '01/01/2013', 103), GETDATE()) / 30.5))), 0)) 
			WHEN (Z_IMINVLOC.qty_on_hand > 0) AND (Z_IMINVLOC_USAGE.usage_ytd IS NULL)
			THEN (ROUND(Z_IMINVLOC.qty_on_ord + Z_IMINVLOC.qty_on_hand, 3))	
			WHEN (Z_IMINVLOC.qty_on_hand <= 0) AND NOT (Z_IMINVLOC_USAGE.usage_ytd IS NULL)
			THEN (ROUND(Z_IMINVLOC.qty_on_ord - (3 * CEILING(dbo.Z_IMINVLOC_USAGE.usage_ytd / (DATEDIFF(day, CONVERT(datetime, '01/01/2013', 103), GETDATE())/ 30.5))), 0)) 
			WHEN (Z_IMINVLOC.qty_on_hand <= 0) AND (Z_IMINVLOC_USAGE.usage_ytd IS NULL)
			THEN (ROUND(Z_IMINVLOC.qty_on_ord,3))
		ELSE '' END AS [QOH+QOO-90], 	
	   */
			
       Z_IMINVLOC.po_min AS MOQ, 
       --'_________' AS [ORDER], 
       IMITMIDX_SQL.item_note_2 AS Supplier,  
       IMITMIDX_SQL.item_note_5 AS [Misc Note (N5)],    
       IMITMIDX_SQL.p_and_ic_cd AS [Rec Loc],     
       Z_IMINVLOC.prior_year_usage AS PYU, 
       dbo.Z_IMINVLOC_USAGE.usage_ytd,     
       CAST(ROUND(Z_IMINVLOC.last_cost, 2, 0) AS DECIMAL(8, 2)) AS LC, 
       CAST(ROUND(Z_IMINVLOC.std_cost, 2, 0) AS DECIMAL(8, 2)) AS SC, 
       IMITMIDX_SQL.drawing_release_no AS [Dwg #], 
       IMITMIDX_SQL.drawing_revision_no AS [Dwg Rev],
	   SLS_COUNT.[COUNT] AS [SLS COUNT YTD],
	   ROUND((Z_IMINVLOC_USAGE.usage_ytd / SLS_COUNT.[COUNT]),0) AS [AVG QPS YTD],
	   STOCK_ORDER.QTY AS [STOCK ORD QTY]	          
           
FROM  dbo.Z_IMINVLOC AS Z_IMINVLOC INNER JOIN
               dbo.imitmidx_sql AS IMITMIDX_SQL ON Z_IMINVLOC.item_no = IMITMIDX_SQL.item_no LEFT OUTER JOIN
               dbo.Z_IMINVLOC_QALL ON dbo.Z_IMINVLOC_QALL.item_no = Z_IMINVLOC.item_no LEFT OUTER JOIN
               dbo.Z_IMINVLOC_USAGE ON dbo.Z_IMINVLOC_USAGE.item_no = Z_IMINVLOC.item_no LEFT OUTER JOIN
               dbo.Z_IMINVLOC_QOH_CHECK AS QC ON QC.item_no = Z_IMINVLOC.item_no LEFT OUTER JOIN
               dbo.BG_WM_Current_Projections AS PROJ ON PROJ.item_no = IMITMIDX_SQL.item_no 
			   LEFT OUTER JOIN BG_OE_SALESORDER_COUNT_YTD AS SLS_COUNT ON SLS_COUNT.item_no = IMITMIDX_SQL.item_no
			   LEFT OUTER JOIN BG_OE_STOCK_ORDER_QTY AS STOCK_ORDER ON STOCK_ORDER.item_no = IMITMIDX_SQL.item_no
WHERE  (Z_IMINVLOC.prod_cat IN ('036', '037', '111', '336', '102','337')) 
		AND IMITMIDX_SQL.activity_cd = 'A'
		--Test
		--AND IMITMIDX_SQL.item_no = 'CR UPR MR BRKT' 
ORDER BY Z_IMINVLOC.item_no