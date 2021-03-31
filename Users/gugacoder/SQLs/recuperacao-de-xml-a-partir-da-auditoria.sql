if object_id('__recuperar_xml_por_auditoria') is not null
  drop procedure __recuperar_xml_por_auditoria
go
create procedure __recuperar_xml_por_auditoria
as
begin
  if object_id('__nfe') is not null
    drop table __nfe
  create table __nfe(
    DFid int not null identity(1,1) primary key,
    DFcaminho_virtual varchar(100),
    DFxml xml
  )

  ; with
  TBnfe as (
    select 
      substring(tag.value('(.//@Id)[1]', 'varchar(100)'),4,44) as DFchave_nfe,
      tag.query('declare default element namespace "http://www.portalfiscal.inf.br/nfe";.') as DFxml
    from sped.TBjob_auditoria
    cross apply DFxml_requisicao.nodes('//*:NFe') as T (tag)
  ),
  TBprot as (
    select 
      tag.value('(.//*:chNFe)[1]', 'varchar(100)') as DFchave_nfe,
      tag.query('declare default element namespace "http://www.portalfiscal.inf.br/nfe";.') as DFxml
    from sped.TBjob_auditoria
    cross apply DFxml_resposta.nodes('//*:protNFe') as T (tag)
    where tag.value('(.//*:cStat)[1]', 'int') = 100
  )
  insert into __nfe(DFcaminho_virtual, DFxml)
  select 
    '/'+TBnfe.DFchave_nfe+'-procNFe.xml' as DFcaminho_virtual,
    CAST(
       '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
      + CAST(TBnfe.DFxml as varchar(max))
      + CAST(TBprot.DFxml as varchar(max))
      +'</nfeProc>'
    AS XML) as DFxml
  from TBnfe
  inner join TBprot
      on TBprot.DFchave_nfe = TBnfe.DFchave_nfe


  -- REMOVENDO DUPLICADOS
  delete from __nfe
   where DFid not in (
      select max(DFid)
        from __nfe
       group by DFcaminho_virtual)


  -- INSERINDO DA VIEW
  insert into vw_xml_nfe (DFcaminho_virtual, DFxml)
  select DFcaminho_virtual, DFxml
    from __nfe
   where DFcaminho_virtual not in (select DFcaminho_virtual from vw_xml_nfe)
end
go
exec __recuperar_xml_por_auditoria
