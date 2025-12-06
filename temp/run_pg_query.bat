@echo off
set PGPASSFILE=C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\.pgpass_temp
psql -h 192.168.6.146 -p 5432 -U refact -d mercados -f "C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp\find_fechas_descuento.sql"
