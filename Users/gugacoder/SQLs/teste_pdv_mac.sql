--select * from mlogic.TBintegracao_item_cupom_fiscal
--select * from mlogic.TBintegracao_cupom_fiscal where dfcod_empresa = 1
--select * from mlogic.TBintegracao_caixa
--select * from mlogic.TBintegracao_sessao
--select * from mlogic.TBintegracao_cupom_fiscal where dfcodigo in (23095,23096,23097,23179,23245,23760)
--select * from mlogic.TBintegracao_item_cupom_fiscal where DFcod_registro_cupom_fiscal in (23095,23096,23097,23179,23245,23760)
--select * from mlogic.TBintegracao_cupom_fiscal where dfcodigo in (35601)
--select * from mlogic.TBintegracao_item_cupom_fiscal where DFcod_registro_cupom_fiscal in (35601)
--exec mlogic.sp_obter_pdvs 4

drop table if exists #TBtemp_2
drop table if exists #TBtemp_loja_04
drop table if exists #TBtemp_loja_01

SELECT TBitem_cupom.DFcod_empresa
     , TBcupom.DFcod_pdv
     , TBcupom.DFdata_movimento as DFdata_abertura
     , TBitem_cupom.DFcod_registro_item AS DFcod_item_estoque
	 , TBcupom.DFcancelado
	 , DFcod_registro_cupom_fiscal
     , SUM(TBitem_cupom.DFquantidade) AS DFquantidade_venda
     , SUM(TBitem_cupom.DFtotal_liquido) AS DFvalor_venda_liquido
     , SUM(round(TBitem_cupom.DFpreco_custo * TBitem_cupom.DFquantidade,2)) AS DFvalor_custo_bruto
  INTO #TBtemp_2
  FROM mlogic.TBintegracao_item_cupom_fiscal AS TBitem_cupom
  INNER JOIN mlogic.TBintegracao_cupom_fiscal AS TBcupom
     ON TBcupom.DFcod_empresa = TBitem_cupom.DFcod_empresa
	AND TBcupom.DFcod_pdv = TBitem_cupom.DFcod_pdv
	AND TBcupom.DFcodigo = TBitem_cupom.DFcod_registro_cupom_fiscal

WHERE TBitem_cupom.DFcancelado = 0
  AND TBcupom.DFdata_movimento >  '2020-09-02 00:00:00' 
  AND NOT EXISTS (SELECT *
                    FROM mlogic.TBintegracao_cupom_fiscal AS TBcupom_cancelado
                   WHERE TBcupom_cancelado.DFcancelado = 1
				     AND TBitem_cupom.DFcod_empresa = TBcupom_cancelado.DFcod_empresa
	                 AND TBitem_cupom.DFcod_pdv = TBcupom_cancelado.DFcod_pdv
	                 AND TBitem_cupom.DFcod_registro_cupom_fiscal = TBcupom_cancelado.DFcodigo) 

GROUP BY TBitem_cupom.DFcod_empresa
     , TBcupom.DFdata_movimento 
     , TBitem_cupom.DFcod_registro_item
	 , TBcupom.DFcancelado
	 , DFcod_registro_cupom_fiscal
	 , TBcupom.DFcod_pdv
ORDER BY TBcupom.DFdata_movimento 


--select * from TBempresa_mercadologic

SELECT 

t.*
INTO #TBtemp_loja_04
FROM OPENROWSET('MSDASQL','Driver={PostgreSQL 64-Bit ODBC Drivers};Server=192.168.4.243;Port=5432;Database=DBMercadologic;Uid=postgres;Pwd=local;',
     'SELECT caixa.numeroloja 
	 , pdv.idecf
	 , coo
     , caixa.datamovimento 
     , itemcupomfiscal.iditem 
	 , itemcupomfiscal.quantidade
     , itemcupomfiscal.totalliquido
     , itemcupomfiscal.precocusto
	 , cupomfiscal.id
  FROM itemcupomfiscal
  JOIN item ON item.id = itemcupomfiscal.iditem 
  JOIN cupomfiscal ON cupomfiscal.id = itemcupomfiscal.idcupomfiscal
  JOIN sessao ON sessao.id = cupomfiscal.idsessao
  JOIN caixa ON sessao.idcaixa = caixa.id
  JOIN pdv ON caixa.idpdv = pdv.id 
WHERE itemcupomfiscal.cancelado = false
 AND cupomfiscal.cancelado = false
 AND caixa.numeroloja = 4
 AND caixa.datamovimento > ''2020-09-02''
 AND pdv.idecf = 1') t

SELECT 

t.*
INTO #TBtemp_loja_01
FROM OPENROWSET('MSDASQL','Driver={PostgreSQL 64-Bit ODBC Drivers};Server=192.168.1.243;Port=5432;Database=DBMercadologic;Uid=postgres;Pwd=local;',
     'SELECT caixa.numeroloja 
	 , pdv.identificador as idecf
	 , coo
     , caixa.datamovimento 
     , itemcupomfiscal.iditem 
	 , itemcupomfiscal.quantidade
     , itemcupomfiscal.totalliquido
     , itemcupomfiscal.precocusto
	 , cupomfiscal.id
  FROM itemcupomfiscal
  JOIN item ON item.id = itemcupomfiscal.iditem 
  JOIN cupomfiscal ON cupomfiscal.id = itemcupomfiscal.idcupomfiscal
  JOIN sessao ON sessao.id = cupomfiscal.idsessao
  JOIN caixa ON sessao.idcaixa = caixa.id
  JOIN pdv ON caixa.idpdv = pdv.id 
WHERE itemcupomfiscal.cancelado = false
 AND cupomfiscal.cancelado = false
 AND caixa.numeroloja = 1
 AND caixa.datamovimento > ''2020-09-02''
 AND pdv.idecf = 11') t


 --select * from #TBtemp_loja_04
 --select * from #TBtemp_2 where DFcancelado = 1


 select numeroloja
      , idecf
      , datamovimento
	  , totalliquido
	  , DFvalor_venda_liquido
 from (

 select numeroloja
      , datamovimento
	  , idecf
      , sum(totalliquido) as totalliquido
	  , DFvalor_venda_liquido
   from #TBtemp_loja_04 
   left join (select DFcod_empresa, DFcod_pdv, cast(DFdata_abertura as date) as dfdata_abertura
                   , sum(DFvalor_venda_liquido) as DFvalor_venda_liquido
				from #TBtemp_2 
			   group by DFcod_empresa, DFcod_pdv, cast(DFdata_abertura as date)) as tbtemp
     on tbtemp.dfdata_abertura = #TBtemp_loja_04.datamovimento
	  and tbtemp.DFcod_empresa = #TBtemp_loja_04.numeroloja
	  and tbtemp.DFcod_pdv = #TBtemp_loja_04.idecf
  
  group by numeroloja, datamovimento, idecf, DFvalor_venda_liquido

 union all

  select numeroloja
      , datamovimento
	  , idecf
      , sum(totalliquido)  as totalliquido
	  , DFvalor_venda_liquido
   from #TBtemp_loja_01 
   left join (select DFcod_empresa, DFcod_pdv, cast(DFdata_abertura as date) as dfdata_abertura
                   , sum(DFvalor_venda_liquido) as DFvalor_venda_liquido
				from #TBtemp_2 
			   group by DFcod_empresa, DFcod_pdv, cast(DFdata_abertura as date)) as tbtemp
     on tbtemp.dfdata_abertura = #TBtemp_loja_01.datamovimento
    and tbtemp.DFcod_empresa = #TBtemp_loja_01.numeroloja
	and tbtemp.DFcod_pdv = #TBtemp_loja_01.idecf
  group by numeroloja, datamovimento, idecf, DFvalor_venda_liquido) as tbtabela

where totalliquido <> isnull(DFvalor_venda_liquido,0)

 order by numeroloja
      , idecf
      , datamovimento

  
  --select id, count(*) from #TBtemp_loja_04 where datamovimento = '2020-09-03' group by id
  --select DFcod_registro_cupom_fiscal, count(*) from #TBtemp_2 where DFcod_empresa = 4 and DFdata_abertura = '2020-09-03' group by DFcod_registro_cupom_fiscal
  --select count(*) from mlogic.TBintegracao_item_cupom_fiscal where dfcod_empresa = 4 and DFdata_abertura = '2020-09-03'
  --  select * from mlogic.TBintegracao_item_cupom_fiscal where dfcod_empresa = 4
   --select id, sum(totalliquido)  from #TBtemp group by id order by id
 --select DFcod_registro_cupom_fiscal, sum(DFvalor_venda_liquido) from #TBtemp_2 group by DFcod_registro_cupom_fiscal order by DFcod_registro_cupom_fiscal
  --where DFcancelado = 1
 --select * from #TBtemp_2 where DFcancelado = 1
  --select * from mlogic.TBintegracao_cupom_fiscal where dfcancelado = 1
--select * from mlogic.TBintegracao_cupom_fiscal
-- where DFcodigo NOT IN (select DFcod_registro_cupom_fiscal from mlogic.TBintegracao_item_cupom_fiscal)
--select * from #TBtemp_loja_04 where coo = 111307
--select id, count(*) from #TBtemp_loja_04 where datamovimento = '2020-09-03'  and coo = 111307 group by id
--select * from mlogic.TBintegracao_cupom_fiscal where dfcoo = 111307
--select * from mlogic.TBintegracao_item_cupom_fiscal where DFcod_registro_cupom_fiscal = 24704

