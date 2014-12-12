- This directory contains all SQL COMMAND which dump data that must be transferred to drupal.
- Part of the SQL COMMAND are replacement pattern and are enclose by '::'.
- All SQL COMMAND in files are launched in Drupal.local_export_drupal

FILE NAME CONVENTION :
xxx.sql
  where
  xxx is the name of the table in drupal db in which the data dumped will be loaded !

FIELDS ORDER CONVENTION :
  fields order must reflect the exact structure of the table in which data will be loaded.
  In other terms, fields orders are the same as shown when a describe request is sent in drupal database against the table.
