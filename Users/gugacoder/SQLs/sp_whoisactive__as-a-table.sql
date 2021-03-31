

IF OBJECT_ID('tempdb..#log') IS NOT NULL DROP TABLE #log

/*
DECLARE @s VARCHAR(MAX)
EXEC sp_WhoIsActive @format_output = 0,@return_schema = 1,@schema = @s OUTPUT
SET @s = REPLACE(@s, '<table_name>', '#log')
SELECT @s
*/

CREATE TABLE #log ( [session_id] smallint NOT NULL,[sql_text] nvarchar(max) NULL,[login_name] nvarchar(128) NOT NULL,[wait_info] nvarchar(4000) NULL,[CPU] int NULL,[tempdb_allocations] bigint NULL,[tempdb_current] bigint NULL,[blocking_session_id] smallint NULL,[reads] bigint NULL,[writes] bigint NULL,[physical_reads] bigint NULL,[used_memory] bigint NOT NULL,[status] varchar(30) NOT NULL,[open_tran_count] smallint NULL,[percent_complete] real NULL,[host_name] nvarchar(128) NULL,[database_name] nvarchar(128) NULL,[program_name] nvarchar(128) NULL,[start_time] datetime NOT NULL,[login_time] datetime NULL,[request_id] int NULL,[collection_time] datetime NOT NULL)
EXEC sp_WhoIsActive @format_output = 0, @destination_table = '#log'

select cast((current_timestamp-start_time) as time(0)) as ellapsed
     , session_id
     , blocking_session_id
     , database_name
     , program_name
     , *
  from #log
  
  
-- Para identificar o ultimo comando de um SPID use:
-- DBCC INPUTBUFFER(SPID_TAL)
  
