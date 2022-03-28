
MERGE T_COST_GL_ACCOUNTS AS Tgt
USING 
(
SELECT		cga.DataSetID ,
			cga.FacilityID ,
			cga.CostCenter ,
			cc.Description CCDesc ,
			cga.Subaccount ,
			cga.CostAccountType ,
			cga.ReclassNumber ,
			mp.AccountCategory ,
			cat.CostCategory ,
			fv.FV + cc.DirectIndirect CostType ,
			cga.Labor 
FROM		T_COST_GL_ACCOUNTS cga
left JOIN				T_COST_CENTERS cc
							ON cc.DataSetID = 'COST2022'
							AND 
						CASE WHEN cga.CostCenter BETWEEN 4000000000000 AND 4999999999999 THEN 2
						WHEN cga.CostCenter BETWEEN 3000000000000 AND 3059999999999 AND cga.CostCenter NOT LIKE '______10349__' THEN 1 
						WHEN cga.CostCenter BETWEEN 3060000000000 AND 3069999999999 THEN 2
						WHEN cga.CostCenter BETWEEN 3070000000000 AND 3999999999999 THEN 1
						WHEN LEFT(CAST(cga.CostCenter as varchar(15)), 1) IN (1) and substring(CAST(cga.CostCenter as varchar(15)), 4, 3)  in (100, 300, 305, 310, 320) THEN 1
						WHEN LEFT(CAST(cga.CostCenter as varchar(15)), 1) IN (1) and substring(CAST(cga.CostCenter as varchar(15)), 4, 1)  = 4 THEN 2
						WHEN LEFT(CAST(cga.CostCenter as varchar(15)), 1) IN (2) then  1
						WHEN cga.CostCenter = 9991009999922 THEN 1
						WHEN cga.CostCenter LIKE '______89999__' THEN 2
						WHEN cga.CostCenter LIKE '______10349__'  THEN 2
						else 0 end = cc.FacilityID
							AND cga.CostCenter  = cc.CostCenter
left join	DSS.COSTING.AccountCategoryMap mp
				on cga.Subaccount = mp.SubAccount
left join	DSS.COSTING.CostCategory cat
				on mp.AccountCategory = cat.AccountCategory

left join	dss.COSTING.aaa_FixedVariable fv
				on cga.SubAccount = fv.Subaccount
				and fv.DataSetID = 'cost2022'
WHERE		cga.DataSetID = 'COST2022'
AND			cga.AccountCategory = ''

) AS Src

ON		Tgt.DataSetID = Src.DataSetID
AND		Tgt.FacilityID = Src.FacilityID 
AND		Tgt.CostCenter = Src.CostCenter
AND		Tgt.CostAccountType = Src.CostAccountType
AND		Tgt.SubAccount = Src.SubAccount
AND		Tgt.ReclassNumber = Src.ReclassNumber
AND		(Tgt.CostCategory = ''
OR		Tgt.CostType = ''
OR		Tgt.AccountCategory = '')

WHEN MATCHED THEN UPDATE
SET		Tgt.CostCategory = Src.CostCategory,
		Tgt.CostType = Src.CostType ,
		Tgt.AccountCategory = Src.AccountCategory;
