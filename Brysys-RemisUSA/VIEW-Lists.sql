ALTER VIEW  [BG_BOM_ALL]
AS
SELECT        item_no AS Parent, comp_item_no AS Component, qty_per_par
FROM            dbo.bmprdstr_sql

GO

ALTER VIEW  [BG_ALL_CUSTOMERS]
AS
SELECT   cus_no, cus_name, addr_1, addr_2, addr_3, city, state, zip, country, phone_no, slspsn_no, ship_via_cd, tax_cd
FROM     dbo.arcusfil_sql

GO

ALTER VIEW  [BG_ALL_VENDORS]
AS
SELECT vend_no, vend_name, addr_1, addr_2, addr_3, city, state, zip, country, phone_no, fax_no, vend_type_cd, ship_via_cd, tax_id, 
				fed_id_type, cat_1099, payee_name, payment_method
FROM   dbo.apvenfil_sql

GO

ALTER VIEW  [BG_IM_ALL]
AS
select item_no, item_desc_1, item_desc_2, prod_cat, uom, price_uom, pur_uom, mfg_uom, item_weight, activity_cd, stocked_fg, 
		controlled_fg, pur_or_mfg, drawing_release_no, drawing_revision_no, cad_drawing_name, item_note_1, item_note_2, item_note_3, item_note_4, item_note_5
from imitmidx_sql

GO

ALTER VIEW  [BG_IL_ALL]
AS
select item_no, loc, status, qty_on_hand, qty_allocated, avg_cost, last_cost, std_cost, sls_price AS ListPrice
from iminvloc_sql

