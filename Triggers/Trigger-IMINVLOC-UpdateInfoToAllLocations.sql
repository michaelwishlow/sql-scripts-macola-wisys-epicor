USE [001]
GO
/****** Object:  Trigger [dbo].[trigUpdateInfoToAllLocations]    Script Date: 02/15/2012 11:19:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[trigUpdateInfoToAllLocations]
ON [dbo].[iminvloc_sql]

AFTER UPDATE

AS

DECLARE @loc varchar(3)

SELECT @loc = loc FROM inserted

if @loc NOT IN ('IN')

BEGIN

UPDATE IMINVLOC_SQL
SET [status] = INS.[status], price = INS.price, avg_cost = INS.avg_cost, last_cost = INS.last_cost, std_cost = INS.std_cost, sls_price = INS.sls_price, frz_cost = INS.frz_cost, prod_cat = INS.prod_Cat, picking_seq = INS.picking_seq, cube_width = ins.cube_width, cube_length = ins.cube_length, cube_height = ins.cube_height, cube_qty_per = ins.cube_qty_per, user_def_fld_1 = ins.user_def_fld_1, user_def_fld_2 = ins.user_def_fld_2, user_def_fld_3 = ins.user_def_fld_3, user_def_fld_4 = ins.user_def_fld_4, user_def_fld_5 = ins.user_def_fld_5, landed_cost_cd = ins.landed_cost_cd, landed_cost_cd_2 = ins.landed_cost_cd_2, landed_cost_cd_3 = ins.landed_cost_cd_3, landed_cost_cd_4 = ins.landed_cost_cd_4, landed_cost_cd_5 = ins.landed_cost_cd_5, landed_cost_cd_6 = ins.landed_cost_cd_6, landed_cost_cd_7 = ins.landed_cost_cd_7, landed_cost_cd_8 = ins.landed_cost_cd_8, landed_cost_cd_9 = ins.landed_cost_cd_9, landed_cost_cd_10 = ins.landed_cost_cd_10 --doc_field_1, doc_field_2, doc_field_3, extra_1, extra_2, extra_3, extra_4, extra_5, extra_6, extra_7, extra_8, extra_9, extra_10, extra_11, extra_12, extra_13, extra_14, extra_15
FROM INSERTED INS
WHERE iminvloc_Sql.item_no = INS.item_no AND IMINVLOC_SQL.loc != 'IN'

END

