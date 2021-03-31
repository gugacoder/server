declare @object_name varchar(max) = 'TBmanifesto_destinatario'

select object_name(parent_object_id) as parent_object
     , object_name(referenced_object_id) as referenced_object
  from sys.foreign_keys
 where parent_object_id = object_id(@object_name)
    or referenced_object_id = object_id(@object_name)
