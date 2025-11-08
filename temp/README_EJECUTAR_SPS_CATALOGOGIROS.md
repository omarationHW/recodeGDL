# 📋 Instrucciones para Ejecutar SPs de Catálogo de Giros

## ⚠️ IMPORTANTE
Los SPs deben crearse en el esquema **`comun`**, NO en `catastro_gdl`.

## 🎯 Pasos para Ejecutar

### Opción 1: Usando psql (Recomendado)

```bash
# 1. Conectarse a PostgreSQL
psql -U postgres -d padron_licencias

# 2. Ejecutar el script maestro
\i C:/Sistemas/RefactorX/Guadalajara/RecodePHP/GDL/RefactorX/Base/padron_licencias/database/ok/DEPLOY_CATALOGOGIROS.sql

# 3. Verificar que se crearon
SELECT proname, pg_get_function_arguments(oid)
FROM pg_proc
WHERE pronamespace = 'comun'::regnamespace
  AND proname LIKE 'sp_catalogogiros%'
ORDER BY proname;
```

### Opción 2: Usando pgAdmin

1. Abrir pgAdmin
2. Conectarse a la base de datos `padron_licencias`
3. Abrir Query Tool
4. Cargar el archivo: `DEPLOY_CATALOGOGIROS.sql`
5. Ejecutar (F5)
6. Verificar resultado en Messages

### Opción 3: Usando DBeaver

1. Conectarse a `padron_licencias`
2. Clic derecho en conexión → SQL Editor → Open SQL Script
3. Seleccionar: `DEPLOY_CATALOGOGIROS.sql`
4. Ejecutar (Ctrl+Enter o botón Play)
5. Verificar en Output

## ✅ Verificación

Después de ejecutar, deberías ver 6 SPs:

```sql
-- Listar SPs creados
SELECT
    routine_schema,
    routine_name,
    routine_type
FROM information_schema.routines
WHERE routine_schema = 'comun'
    AND routine_name LIKE 'sp_catalogogiros%'
ORDER BY routine_name;
```

**Resultado esperado:**
```
 routine_schema |         routine_name          | routine_type
----------------+-------------------------------+--------------
 comun          | sp_catalogogiros_cambiar_vigencia | FUNCTION
 comun          | sp_catalogogiros_create       | FUNCTION
 comun          | sp_catalogogiros_estadisticas | FUNCTION
 comun          | sp_catalogogiros_get          | FUNCTION
 comun          | sp_catalogogiros_list         | FUNCTION
 comun          | sp_catalogogiros_update       | FUNCTION
(6 rows)
```

## 🧪 Prueba Rápida

```sql
-- Probar estadísticas
SELECT * FROM comun.sp_catalogogiros_estadisticas();

-- Probar listado (primera página, 10 registros, solo vigentes)
SELECT * FROM comun.sp_catalogogiros_list(1, 10, NULL, NULL, NULL, NULL, 'V');
```

## ❌ Errores Comunes

### Error: "relation comun.c_giros does not exist"
**Solución:** Verifica que la tabla existe:
```sql
SELECT * FROM comun.c_giros LIMIT 1;
```

### Error: "schema comun does not exist"
**Solución:** Crea el esquema:
```sql
CREATE SCHEMA IF NOT EXISTS comun;
```

### Error: "permission denied"
**Solución:** Otorga permisos al usuario:
```sql
GRANT USAGE ON SCHEMA comun TO tu_usuario;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA comun TO tu_usuario;
```

## 📁 Ubicación de Archivos

- **Script maestro:** `RefactorX/Base/padron_licencias/database/ok/DEPLOY_CATALOGOGIROS.sql`
- **SPs individuales:** `RefactorX/Base/padron_licencias/database/ok/sp_catalogogiros_*.sql`

## 🔄 Re-ejecución

Si necesitas re-ejecutar los SPs:
1. El script usa `CREATE OR REPLACE`, así que es seguro ejecutarlo múltiples veces
2. NO borrará datos de la tabla `comun.c_giros`
3. Solo actualizará la lógica de los SPs

## 📞 Soporte

Si tienes problemas:
1. Verifica que estás conectado a la BD correcta
2. Revisa que el usuario tiene permisos
3. Comprueba que la tabla `comun.c_giros` existe y tiene datos
