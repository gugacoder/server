if object_id('mlogic.sp_replicar_tabela') is not null
  drop procedure mlogic.sp_replicar_tabela
GO
create procedure mlogic.sp_replicar_tabela
  @tabela varchar(100),
  @ip_pdv varchar(100),
  @banco varchar(100) = 'DBPDV',
  @usuario varchar(100) = 'postgres',
  @senha varchar(100) = 'local'
as
-- Procedure de importa��o de dados do PDV.
--
-- Os dados s�o copiados de uma tabela de replica��o do PDV
-- com o padr�o de nome "integracao.nome_da_tabela" para a tabela
-- correspondente no director com o padr�o de nome "mlogic.TBintegracao_nome_da_tabela.
--
-- S�o copiados todos os registros no PDV marcados como n�o integrados.
-- Os registros no PDV s�o marcados como integrados depois da c�pia.
begin
  declare @sql nvarchar(max)

  -- M�ximo de registros atualizados por execucao
  --
  declare @max nvarchar(3) = '100'

  set @sql = '
    declare @TBinseridos table (DFcod_registro int)

    insert into mlogic.TBintegracao_'+@tabela+'
    output inserted.DFcod_registro into @TBinseridos
    select top '+@max+' *
      from openrowset(
        ''MSDASQL'',
        ''Driver={PostgreSQL 64-Bit ODBC Drivers};Server='+@ip_pdv+';Port=5432;Database='+@banco+';Uid='+@usuario+';Pwd='+@senha+';'',
        ''select * from integracao.'+@tabela+'''
      ) as tabela
     where tabela.integrado = 0

    update tabela
       set integrado = 1
      from openrowset(
        ''MSDASQL'',
        ''Driver={PostgreSQL 64-Bit ODBC Drivers};Server='+@ip_pdv+';Port=5432;Database='+@banco+';Uid='+@usuario+';Pwd='+@senha+';'',
        ''select * from integracao.'+@tabela+'''
      ) as tabela
     where cod_registro in (select DFcod_registro from @TBinseridos)

    -- imprimindo os registros afetados
    select * from @TBinseridos
  '
  exec sp_executesql @sql
end
go

exec mlogic.sp_replicar_tabela 'documento_nao_fiscal', '192.168.4.101'

go
