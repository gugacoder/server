-- 15:39
-- 15:41
-- 15:42
-- 15:44
-- 15:46
declare @date datetime = '2020-07-14 15:46'

select total, tabela from (
          select 'caixa'                   as tabela, count(1) as total from mlogic.TBintegracao_caixa                    where DFdata_integracao >= @date
union all select 'sessao'                  as tabela, count(1) as total from mlogic.TBintegracao_sessao                   where DFdata_integracao >= @date
union all select 'cesta_basica_cupom'      as tabela, count(1) as total from mlogic.TBintegracao_cesta_basica_cupom       where DFdata_integracao >= @date
union all select 'comprovante_nao_fiscal'  as tabela, count(1) as total from mlogic.TBintegracao_comprovante_nao_fiscal   where DFdata_integracao >= @date
union all select 'correspondente_bancario' as tabela, count(1) as total from mlogic.TBintegracao_correspondente_bancario  where DFdata_integracao >= @date
union all select 'cupom_fiscal'            as tabela, count(1) as total from mlogic.TBintegracao_cupom_fiscal             where DFdata_integracao >= @date
union all select 'cupom_fiscal_eletronico' as tabela, count(1) as total from mlogic.TBintegracao_cupom_fiscal_eletronico  where DFdata_integracao >= @date
union all select 'dados_tef_dedicado'      as tabela, count(1) as total from mlogic.TBintegracao_dados_tef_dedicado       where DFdata_integracao >= @date
union all select 'devolucao'               as tabela, count(1) as total from mlogic.TBintegracao_devolucao                where DFdata_integracao >= @date
union all select 'documento_nao_fiscal'    as tabela, count(1) as total from mlogic.TBintegracao_documento_nao_fiscal     where DFdata_integracao >= @date
union all select 'forma_pagamento_efetuada'as tabela, count(1) as total from mlogic.TBintegracao_forma_pagamento_efetuada where DFdata_integracao >= @date
union all select 'item_cesta_basica_cupom' as tabela, count(1) as total from mlogic.TBintegracao_item_cesta_basica_cupom  where DFdata_integracao >= @date
union all select 'item_cupom_fiscal'       as tabela, count(1) as total from mlogic.TBintegracao_item_cupom_fiscal        where DFdata_integracao >= @date
union all select 'item_devolucao'          as tabela, count(1) as total from mlogic.TBintegracao_item_devolucao           where DFdata_integracao >= @date
union all select 'movimento_diario'        as tabela, count(1) as total from mlogic.TBintegracao_movimento_diario         where DFdata_integracao >= @date
union all select 'pagamento_tef'           as tabela, count(1) as total from mlogic.TBintegracao_pagamento_tef            where DFdata_integracao >= @date
union all select 'recarga_celular'         as tabela, count(1) as total from mlogic.TBintegracao_recarga_celular          where DFdata_integracao >= @date
union all select 'retorno_sefaz'           as tabela, count(1) as total from mlogic.TBintegracao_retorno_sefaz            where DFdata_integracao >= @date
union all select 'sangria'                 as tabela, count(1) as total from mlogic.TBintegracao_sangria                  where DFdata_integracao >= @date
union all select 'suprimento'              as tabela, count(1) as total from mlogic.TBintegracao_suprimento               where DFdata_integracao >= @date
) as t
where total > 0
order by tabela
