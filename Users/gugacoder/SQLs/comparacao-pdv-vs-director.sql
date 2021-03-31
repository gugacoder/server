--select * from mlogic.TBintegracao_item_cupom_fiscal
--select * from mlogic.TBintegracao_cupom_fiscal where dfcancelado = 1
--select * from mlogic.TBintegracao_caixa
--select * from mlogic.TBintegracao_sessao
--select * from mlogic.TBintegracao_cupom_fiscal where dfcodigo in (23095,23096,23097,23179,23245,23760)
--select * from mlogic.TBintegracao_item_cupom_fiscal where DFcod_registro_cupom_fiscal in (23095,23096,23097,23179,23245,23760)
--select * from mlogic.TBintegracao_cupom_fiscal where dfcodigo in (35601)
--select * from mlogic.TBintegracao_item_cupom_fiscal where DFcod_registro_cupom_fiscal in (35601)

drop table ##TBtemp_2
drop table ##TBtemp

SELECT TBitem_cupom.DFcod_empresa
     , TBcupom.DFdata_abertura
     , TBitem_cupom.DFcod_registro_item AS DFcod_item_estoque
	 , TBcupom.DFcancelado
	 , DFcod_registro_cupom_fiscal
     , SUM(TBitem_cupom.DFquantidade) AS DFquantidade_venda
     , SUM(TBitem_cupom.DFtotal_liquido) AS DFvalor_venda_liquido
     , SUM(round(TBitem_cupom.DFpreco_custo * TBitem_cupom.DFquantidade,2)) AS DFvalor_custo_bruto
  INTO ##TBtemp_2
  FROM mlogic.TBintegracao_item_cupom_fiscal AS TBitem_cupom
  INNER JOIN mlogic.TBintegracao_cupom_fiscal AS TBcupom
     ON TBcupom.DFcod_empresa = TBitem_cupom.DFcod_empresa
	AND TBcupom.DFcod_pdv = TBitem_cupom.DFcod_pdv
	AND TBcupom.DFcodigo = TBitem_cupom.DFcod_registro_cupom_fiscal

WHERE TBitem_cupom.DFcancelado = 0
  AND TBcupom.DFdata_abertura between  '2020-08-26 00:00:00' and '2020-09-02 23:59:00'
  AND TBcupom.DFcod_pdv = 1
  AND NOT EXISTS (SELECT *
                    FROM mlogic.TBintegracao_cupom_fiscal AS TBcupom_cancelado
                   WHERE TBcupom_cancelado.DFcancelado = 1
				     AND TBitem_cupom.DFcod_empresa = TBcupom_cancelado.DFcod_empresa
	                 AND TBitem_cupom.DFcod_pdv = TBcupom_cancelado.DFcod_pdv
	                 AND TBitem_cupom.DFcod_registro_cupom_fiscal = TBcupom_cancelado.DFcodigo) 

GROUP BY TBitem_cupom.DFcod_empresa
     , TBcupom.DFdata_abertura 
     , TBitem_cupom.DFcod_registro_item
	 , TBcupom.DFcancelado
	 , DFcod_registro_cupom_fiscal
ORDER BY TBcupom.DFdata_abertura 



SELECT 

t.*
INTO ##TBtemp
FROM OPENROWSET('MSDASQL','Driver={PostgreSQL 64-Bit ODBC Drivers};Server=192.168.4.243;Port=5432;Database=DBMercadologic;Uid=postgres;Pwd=local;',
     'SELECT caixa.numeroloja 
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
 AND caixa.datamovimento > ''2020-08-25''
 AND pdv.idecf = 1') t


 --select * from ##TBtemp
 --select * from ##TBtemp_2 where DFcancelado = 1

 select datamovimento
      , sum(totalliquido) 
	  , DFvalor_venda_liquido
   from ##TBtemp 
   left join (select cast(DFdata_abertura as date) as dfdata_abertura
                   , sum(DFvalor_venda_liquido) as DFvalor_venda_liquido
				from ##TBtemp_2 
			   group by cast(DFdata_abertura as date)) as tbtemp
     on tbtemp.dfdata_abertura = ##TBtemp.datamovimento
  
  group by datamovimento, DFvalor_venda_liquido
  having sum(totalliquido) <> DFvalor_venda_liquido
 order by datamovimento


 
 


 --select id, sum(totalliquido)  from ##TBtemp group by id order by id
 --select DFcod_registro_cupom_fiscal, sum(DFvalor_venda_liquido) from ##TBtemp_2 group by DFcod_registro_cupom_fiscal order by DFcod_registro_cupom_fiscal
 
 
 
 
 --where DFcancelado = 1
 --select * from ##TBtemp_2 where DFcancelado = 1




 --select * from mlogic.TBintegracao_cupom_fiscal where dfcancelado = 1

