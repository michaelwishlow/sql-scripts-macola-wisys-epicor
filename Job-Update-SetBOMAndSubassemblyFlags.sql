--Created:	2/15/12		 By:	BG
--Last Updated:	05/15/13	 By:	BG
--Purpose:	Script for job that updates BOM and subassembly flags on the item master
--Last changes: 1) Addes sub assembly flags
--INFO: extra_1 is a field that shows if an item is a parent (P), subassembly (S), component (C), or stand alone items (null).  Extra_2 is a flag that shows 'Y' if item is a parent to any other item and 'N' if not, extra_3 is a flag that shows 'Y' if an item is a subassembly and 'N' if not 

--Reset all flags to null or 'N'
UPDATE imitmidx_sql
SET extra_2 = 'N', extra_3 = 'N', extra_1 = 'X'

--Find items with BOMs and mark them as a parent
UPDATE imitmidx_sql
SET extra_2 = 'Y'
WHERE imitmidx_sql.item_no IN (SELECT item_no FROM bmprdstr_sql)
 /*AND item_no not IN 
	('11906 BS HLDR A',	'58685-2D ZBK',	'58685-2E ZBK',	'ANGLED-03 SS',	'BAK-618 B SHF O',	'BAK-619 BASE',	'BAK-619METCS SB',	'BAK-619 L WM WF',	'BAK-619METCS SB',	'BAK-816 OBV-077',	'BAK-816 OBV-097',	'BAK-NEST PED WR',	'BHC-17 WMBV',	'BH-VEG 628 BK',	'BR-KIT 30 OBV97',	'BR-KIT 48 OBV97',	'BSC-001 L WM BK',	'BSC-001 R WM BK',	'BSC-16UNIV WMBV',	'BSC-18 WMBV',	'BSC-ET14 TTC SB',	'BT-002 45 HICK',	'BT-002 45 OAK',	'CB-28 MB L BK',	'CB-28 MB R BK',	'CB-64 6TRK OAK',	'CH-463 C FRAME',	'CH-463 EC F&GP',	'CH-463 LC SHELF',	'CH-463 RC SHELF',	'CH-484 F AND GP',	'CH-484 L BASE',	'CH-484 R BASE',	'CH-484L SHELVES',	'CHMET06O48X36BK',	'CHMFS-003 GB KD',	'DELI-65 RSR BK',	'DELI-77 BK',	'DELI-78 BK',	'DR-313 BK',	'DR-313 CD Z CL',	'DVD SHELF SET',	'EC-247 O BV A',	'EC-247 O BV B',	'ECKIT-4 OBV097A',	'ECKIT-5 OBV097A',	'ECKIT-6 OBV097A',	'ET14 SCALE GB',	'ET-500 OSB10',	'EUROEC2-OBV97',	'EUROEC5-OSB10',	'EUROTBL1-OBV97A',	'EUROTBL1-OBV97B',	'FL-CHOD',	'FPU-003 WM BV A',	'FPU-003 WM BV B',	'FPU-006 SB A',	'FPU-006 SB B',	'FPU-007 SB A',	'FPU-007 SB B',	'FPU-008 SB A',	'FPU-008 SB B',	'FSC-001',	'FSC-001 WM',	'GRO-010 WM BV A',	'GRO-010 WM GB A',	'GRO-010 WM OW A',	'GRO-011 WM BV A',	'GRO-011 WM BV B',	'GRO-011 WM BV C',	'GRO-011 WM GB A',	'GRO-011 WM GB B',	'GRO-011 WM OW A',	'GRO-011 WM OW B',	'GRO-011 WM OW C',	'GRO-020 WM GB A',	'GRO-020 WM GB B',	'GTO-F&C BK',	'GTR-F&C BK',	'MD-HU PS 48" SB',	'MD-0032 HU SB',	'MDWM-0002 SBCAN',	'MDWM-0003 SBCAN',	'MET-BRD SB',	'MET-BSKT 01 RSV',	'MET-BSKT 02 RSV',	'MET-EC 001BRNSB',	'MET-HANG RL RSV',	'MET-HNG ARM RSV',	'MET-HNG KIT1RSV',	'MET-HNG KIT2RSV',	'MET-HNG KIT3RSV',	'MET-RACK 01 RSV',	'MET-RACK 02 RSV',	'MET-SIDEKICKRSV',	'MET-SM 004 L WM',	'MET-SM 004 R WM',	'MET-WR DVDR RSV',	'MET-WR DVDR2RSV',	'MET-WR RACK RSV',	'MET-WR RACK2RSV',	'OB-361425 O SB',	'OBKIT-3 OBV97CH',	'OBP-18X22X27 CH',	'OBP-18X22X3 BK',	'OBP-36X36X3 BK',	'OBP-36X36X33 CH',	'OBP-40X48X33 CH',	'OBP-40X48X8 BK',	'OCT-40X47 RI BK',	'PCM-003 SS',	'PS-10 F',	'PS-12 F',	'PS-4 G',	'SH-GP SM 7 BV',	'SH-GP SM 8 BV',	'SH-MET435 GN SB',	'ST-01 12" AZCL',	'ST-01 12" BZCL',	'SW00100',	'SW00134BK',	'SW00753BK',	'SW10071',	'SW10073LNR-2 CL',	'SW10073TAN COOKIE',	'TLB-01 BK',	'TLB-02 BK',	'VEG-106 BH CUP',	'VEG-627 WM BK',	'VEG-628 PS SV',	'VEG-EUROTBL1OZA',	'VEG-EUROTBL1OZB','VEG-EUROTBL2OZA',	'VEG-EUROTBL2OZB',	'VEG-SR BRKT BV',	'VVS-2TRACK KIT',	'VVS-SGN 3TRK',	'WBD-006 SB',    'WBH-005 ARTBRD',	'WK-18X48X84 GY',	'WK-24X48X36 CHR',	'WK-24X48X64 CHR',	'WK-24X48X84 CHR',	'WM-LHF LEG CAP',	'WM-VCSGNHLDR',	'X-METAL BASES',	'ZN100',	'OBP-40X48X3 BK'))*/

UPDATE imitmidx_sql
SET extra_1 = 'P'
WHERE imitmidx_sql.item_no IN (SELECT item_no FROM bmprdstr_sql)

--Find items with no BOMs and mark them as Components

UPDATE imitmidx_sql
SET extra_1 = 'C'
WHERE imitmidx_sql.item_no IN (SELECT comp_item_no FROM bmprdstr_sql)

--Find subassemblies (items that are both parents and components) and mark them
UPDATE dbo.imitmidx_sql
SET extra_3 = 'Y'
WHERE item_no IN (SELECT comp_item_no FROM dbo.bmprdstr_sql BM) AND item_no IN (SELECT item_no FROM dbo.bmprdstr_sql BM)

UPDATE dbo.imitmidx_sql
SET extra_1 = 'S'
WHERE item_no IN (SELECT comp_item_no FROM dbo.bmprdstr_sql BM) AND item_no IN (SELECT item_no FROM dbo.bmprdstr_sql BM)


