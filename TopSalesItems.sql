/****** Script for SelectTopNRows command from SSMS  ******/
SELECT SUM([Qty To Ship]*[Unit Price]) AS SlsTotal, Item, [Product Category]
  FROM [001].[dbo].[Z_SALES_HISTORY_2010]
  WHERE NOT([Product Category] IN ('336','102','111','036','037','2')) AND 
	item in (SELECT item_no FROM poordlin_sql AS PL WHERE  (LTRIM(PL.vend_no) IN ('1697', '8830', '9516', '1648', '91202', 
                      '8859', '9523', '9533', '1620', '1613', '23077', '50', '1717', '9703') AND PL.receipt_dt > '2009-03-01 00:00:00.000'))
  GROUP BY Item, [Product Category] 
  ORDER BY SlsTotal DESC, [Product Category]
  
  