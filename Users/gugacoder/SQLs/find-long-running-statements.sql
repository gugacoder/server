select top 10
       r.session_id as sessao
     , db_name(r.database_id) as banco
     , convert(varchar, dateadd(ms, r.total_elapsed_time, 0), 114) as duracao
     , r.start_time as inicio
     , r.command as comando
     , substring (
         t.text, r.statement_start_offset / 2, 
         (
           case r.statement_end_offset when -1 
             then datalength(t.text)
             else r.statement_end_offset
           end
           -
           r.statement_start_offset
         ) / 2
       ) as sql
     , t.[text] as script
     , p.query_plan as plano_de_execucao
  from sys.dm_exec_requests as r
 cross apply sys.dm_exec_sql_text(r.sql_handle) as t
 cross apply sys.dm_exec_query_plan(r.plan_handle) AS p
 order by r.total_elapsed_time desc
 

 