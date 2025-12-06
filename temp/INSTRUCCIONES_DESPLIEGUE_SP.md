# Instrucciones de Despliegue: sp_get_locales

## Problema Persistente
El error sigue apareciendo porque el SP **no se ha desplegado a la base de datos** aún.

```
ERROR: relation "ta_11_locales" does not exist
```

## 🚀 Opciones de Despliegue

### Opción 1: Usar psql (Recomendado)

Desde una terminal con acceso al servidor PostgreSQL:

```bash
psql -h 192.168.20.31 -p 5432 -U postgres -d ingresos -f temp/fix_sp_get_locales.sql
```

O si estás en el servidor:
```bash
psql -U postgres -d ingresos -f temp/fix_sp_get_locales.sql
```

### Opción 2: Usar pgAdmin

1. Abre pgAdmin
2. Conecta al servidor 192.168.20.31
3. Selecciona la base de datos `ingresos`
4. Abre Query Tool
5. Copia y pega el contenido de `temp/fix_sp_get_locales.sql`
6. Ejecuta (F5)

### Opción 3: Ejecutar SQL Directo

Si tienes una consola psql abierta:

```sql
\c ingresos

CREATE OR REPLACE FUNCTION sp_get_locales(p_id_local integer)
RETURNS TABLE (
    id_local integer,
    oficina smallint,
    num_mercado smallint,
    categoria smallint,
    seccion varchar,
    letra_local varchar,
    bloque varchar,
    nombre varchar,
    descripcion_local varchar
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.id_local, a.oficina, a.num_mercado, a.categoria, a.seccion,
           a.letra_local, a.bloque, a.nombre, a.descripcion_local
    FROM public.ta_11_locales a
    WHERE a.id_local = p_id_local;
END;
$$ LANGUAGE plpgsql;
```

### Opción 4: Script PHP desde el servidor

Si estás en el servidor donde está PostgreSQL:

```bash
php temp/deploy_sp_get_locales_fix.php
```

### Opción 5: Script BAT (Windows)

```cmd
temp\desplegar_sp_get_locales.bat
```

## ✅ Verificación después del Despliegue

Verifica que el SP se haya creado correctamente:

```sql
-- Ver la definición del SP
\df+ sp_get_locales

-- Probar el SP
SELECT * FROM sp_get_locales(1);
```

## 🔍 Diagnóstico

Si sigues teniendo problemas, verifica:

1. **¿La tabla existe?**
```sql
SELECT schemaname, tablename
FROM pg_tables
WHERE tablename = 'ta_11_locales';
```

2. **¿El SP existe?**
```sql
SELECT proname, pg_get_functiondef(oid)
FROM pg_proc
WHERE proname = 'sp_get_locales';
```

3. **¿El SP usa el schema correcto?**
Debe mostrar `FROM public.ta_11_locales` en la definición.

## ⚠️ Nota Importante

Los archivos fuente (.sql) ya están corregidos. Solo falta **ejecutar el despliegue** en la base de datos para que el cambio tenga efecto.

## 📁 Archivos Disponibles

- ✅ `temp/fix_sp_get_locales.sql` - Script SQL directo
- ✅ `temp/deploy_sp_get_locales_fix.php` - Script PHP
- ✅ `temp/desplegar_sp_get_locales.bat` - Script BAT para Windows
- ✅ `RefactorX/Base/mercados/database/ok/45_SP_MERCADOS_DATOSREQUERIMIENTOS_EXACTO_all_procedures.sql` - Archivo consolidado

Cualquiera de estos puede usarse para desplegar la corrección.
