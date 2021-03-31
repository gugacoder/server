drop table if exists #TBrelatorio

go

create table #TBrelatorio (
  DFcod_empresa int,
  DFcod_pdv int,
  DFtabela varchar(30),
  DFcod_registro int,
  DFdata_integracao datetime,
  --  -1: Existe apenas no PDV
  --   0: Existe em ambos (Embora seja omitido no resultado geral)
  --   1: Existe apenas no Director
  DFstatus int,
  DFmotivo varchar(100)
)

go

create or alter procedure #comparar_tabela
  @cod_empresa int,
  @cod_pdv int,
  @tabela varchar(30),
  @data_inicial varchar(10) = '2020-09-01'
as
begin
  declare @ip_pdv varchar(15)

  if (@cod_pdv < 10)
    set @ip_pdv = concat('192.168.', @cod_empresa, '.10', @cod_pdv)
  else
    set @ip_pdv = concat('192.168.', @cod_empresa, '.1', @cod_pdv)

  if @tabela like 'TB%'
  begin
    set @tabela = substring(@tabela, 3, len(@tabela))
  end

  declare @sql nvarchar(max) = '
    ; with pdv as (
      select *
        from openrowset(
        ''MSDASQL'',
        ''Driver={PostgreSQL 64-Bit ODBC Drivers};Server=' + @ip_pdv + ';Port=5432;Database=DBPDV;Uid=postgres;Pwd=local;'',
        ''select *
            from integracao.' + @tabela + '
           where data_integracao >= ''''' + @data_inicial + '''''
        ''
      ) as target
    ), director as (
      select * from mlogic.TBintegracao_' + @tabela + ' with (nolock)
      where DFcod_empresa = ' + cast(@cod_empresa as nvarchar(max)) + '
        and DFcod_pdv = ' + cast(@cod_pdv as nvarchar(max)) + '
        and DFdata_integracao >= ''' + @data_inicial + '''
    )
    select coalesce(pdv.cod_empresa, director.DFcod_empresa) as DFcod_empresa
         , coalesce(pdv.cod_pdv, director.DFcod_pdv) as DFcod_pdv
         , ''' + @tabela + ''' as DFtabela
         , coalesce(pdv.cod_registro, director.DFcod_registro) as DFcod_registro
         , coalesce(pdv.data_integracao, director.DFdata_integracao) as DFdata_integracao
         , case
              when pdv.cod_registro is null then 1
              when director.DFcod_registro is null then -1
              else 0
           end as DFstatus
         , case
              when pdv.cod_registro is null then ''Não existe no PDV.''
              when director.DFcod_registro is null then ''Não existe no Director.''
           end as DFmotivo
      from pdv with (nolock)
      full join director with (nolock)
             on director.DFcod_empresa = pdv.cod_empresa
            and director.DFcod_registro = pdv.cod_registro
     where pdv.cod_registro is null
        or director.DFcod_registro is null'

  insert into #TBrelatorio
    exec sp_executesql @sql

end

go

create or alter procedure #comparar_tabelas
  @cod_empresa int,
  @cod_pdv int,
  @data_inicial varchar(10) = '2020-09-01'
as
begin
  declare @error nvarchar(400)
  
  set @error =
      'comparar_tabelas: '
    + 'emp:' + cast(@cod_empresa as varchar(100)) + ', '
    + 'pdv:' + cast(@cod_pdv as varchar(100)) + ', '
    + 'dte:'+ @data_inicial
  raiserror (@error,10,1) with nowait
  
  begin try
    declare @id int
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'cupom_fiscal'            , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'item_cupom_fiscal'       , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'documento_nao_fiscal'    , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'comprovante_nao_fiscal'  , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'item_cesta_basica_cupom' , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'item_devolucao'          , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'item_pre_venda'          , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'pagamento_tef'           , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'caixa'                   , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'cesta_basica_cupom'      , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'correspondente_bancario' , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'cupom_fiscal_eletronico' , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'dados_tef_dedicado'      , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'devolucao'               , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'forma_pagamento_efetuada', @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'inutilizacao_sefaz'      , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'movimento_diario'        , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'pre_venda'               , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'recarga_celular'         , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'retorno_sefaz'           , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'sangria'                 , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'sessao'                  , @data_inicial ;
    exec #comparar_tabela @cod_empresa, @cod_pdv, 'suprimento'              , @data_inicial ;
  end try
  begin catch
    set @error = error_message()
    raiserror (@error,10,1) with nowait
  end catch
end

go
/*
exec #comparar_tabelas 1, 5 , '2020-09-01';
exec #comparar_tabelas 1, 6 , '2020-09-01';
exec #comparar_tabelas 1, 7 , '2020-09-01';
exec #comparar_tabelas 1, 8 , '2020-09-01';
exec #comparar_tabelas 1, 9 , '2020-09-01';
exec #comparar_tabelas 1, 10, '2020-09-01';
exec #comparar_tabelas 1, 11, '2020-09-01';
exec #comparar_tabelas 1, 12, '2020-09-01';
exec #comparar_tabelas 1, 13, '2020-09-01';
exec #comparar_tabelas 1, 14, '2020-09-01';
exec #comparar_tabelas 1, 15, '2020-09-01';
exec #comparar_tabelas 1, 16, '2020-09-01';
exec #comparar_tabelas 1, 17, '2020-09-01';
exec #comparar_tabelas 1, 18, '2020-09-01';
exec #comparar_tabelas 1, 19, '2020-09-01';
exec #comparar_tabelas 1, 20, '2020-09-01';
*/
exec #comparar_tabelas 4, 1 , '2020-09-01';
exec #comparar_tabelas 4, 2 , '2020-09-01';
exec #comparar_tabelas 4, 3 , '2020-09-01';
exec #comparar_tabelas 4, 4 , '2020-09-01';
exec #comparar_tabelas 4, 5 , '2020-09-01';
exec #comparar_tabelas 4, 6 , '2020-09-01';
exec #comparar_tabelas 4, 7 , '2020-09-01';
exec #comparar_tabelas 4, 8 , '2020-09-01';
exec #comparar_tabelas 4, 9 , '2020-09-01';
exec #comparar_tabelas 4, 10, '2020-09-01';
exec #comparar_tabelas 4, 11, '2020-09-01';
exec #comparar_tabelas 4, 12, '2020-09-01';
exec #comparar_tabelas 4, 13, '2020-09-01';
exec #comparar_tabelas 4, 14, '2020-09-01';

/*
drop table if exists __relatorio__
select *
  into __relatorio__
  from #TBrelatorio
*/

insert into __relatorio__ select * from #TBrelatorio

select * from __relatorio__

/*
select * from mlogic.TBintegracao_cupom_fiscal_eletronico where dfcod_registro = 3676

update mlogic.TBintegracao_item_cupom_fiscal
set DFcod_empresa = -DFcod_empresa
where dfcod_empresa < 0

update target
   set target.integrado = 0
  from openrowset(
    'MSDASQL',
    'Driver={PostgreSQL 64-Bit ODBC Drivers};Server=192.168.4.101;Port=5432;Database=DBPDV;Uid=postgres;Pwd=local;',
    'select * from integracao.documento_nao_fiscal'
  ) as target
 where cod_registro in (688, 689)

select * from mlogic.TBintegracao_documento_nao_fiscal
 where dfcod_registro in (688, 689)

delete from  mlogic.TBintegracao_documento_nao_fiscal where
dfcod_empresa = 4 and dfcod_registro = 689
*/
