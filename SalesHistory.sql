SELECT  OH.ord_no, OH.entered_dt, item_no, qty_ordered, qty_to_ship, OH.cus_alt_adr_cd, ship_to_addr_1, ship_to_addr_2, ship_to_addr_4, OH.cus_no, AR.cus_name
FROM    oehdrhst_sql OH INNER JOIN oelinhst_sql OL ON OH.inv_no = OL.inv_no JOIN arcusfil_sql AR ON AR.cus_no = OH.cus_no
WHERE ship_to_addr_4 like '%, CA%' OR ship_to_addr_4 like '%, NV%' AND entered_dt > '01/01/2010' AND not(item_no like '%test%')