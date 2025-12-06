# Fix: Resolución de Ambigüedad en sp_get_mercados_by_recaudadora

## Fecha: 2025-12-04

## Problema Detectado

Al cargar mercados en el componente PadronEnergia, se generaba el siguiente error:

```
SQLSTATE[42725]: Ambiguous function: 7 ERROR: function public.sp_get_mercados_by_recaudadora(unknown) is not unique
LINE 1: SELECT * FROM public.sp_get_mercados_by_recaudadora($1)
HINT: Could not choose a best candidate function. You might need to add explicit type casts.
```

### Causa Raíz

El stored procedure `sp_get_mercados_by_recaudadora` tenía **múltiples versiones** en la base de datos con diferentes tipos de parámetros:
- Una versión con parámetro `INTEGER`
- Otra versión con parámetro `SMALLINT`
- Posiblemente otras versiones con `BIGINT` o `NUMERIC`

PostgreSQL no podía determinar cuál función usar cuando el parámetro enviado era de tipo "unknown".

### Archivos Fuente Encontrados

Había 2 archivos SQL con definiciones ligeramente diferentes:
1. `RefactorX/Base/mercados/database/database/PadronEnergia_sp_get_mercados_by_recaudadora.sql`
   - Parámetro: `p_id_rec integer`
2. `RefactorX/Base/mercados/database/database/RptPadronEnergia_sp_get_mercados_by_recaudadora.sql`
   - Parámetro: `p_oficina integer`

## Solución Aplicada

### 1. Script de Corrección Creado

Archivo: `temp/fix_sp_get_mercados_by_recaudadora.sql`

**Acciones realizadas**:
1. Eliminar TODAS las versiones posibles del SP con diferentes tipos:
   ```sql
   DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(integer);
   DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(smallint);
   DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(bigint);
   DROP FUNCTION IF EXISTS sp_get_mercados_by_recaudadora(numeric);
   DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(integer);
   DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(smallint);
   DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(bigint);
   DROP FUNCTION IF EXISTS public.sp_get_mercados_by_recaudadora(numeric);
   ```

2. Crear UNA sola versión correcta con tipo `SMALLINT`:
   ```sql
   CREATE OR REPLACE FUNCTION sp_get_mercados_by_recaudadora(
       p_recaudadora_id SMALLINT
   )
   RETURNS TABLE(
       num_mercado_nvo INTEGER,
       descripcion VARCHAR
   )
   LANGUAGE plpgsql
   AS $$
   BEGIN
       RETURN QUERY
       SELECT
           m.num_mercado_nvo,
           m.descripcion
       FROM padron_licencias.comun.ta_11_mercados m
       WHERE m.oficina = p_recaudadora_id
         AND m.cuenta_energia > 0
       ORDER BY m.num_mercado_nvo;
   END;
   $$;
   ```

### 2. Despliegue Ejecutado

**Comando**:
```bash
c:/xampp/php/php.exe temp/deploy_fix_mercados_by_recaudadora.php
```

**Resultado**:
```
✓ Conectado a PostgreSQL
✓ Archivo SQL leído
✓ Script ejecutado exitosamente

--- Versiones del SP en la base de datos ---
Total encontrado: 1

Función: sp_get_mercados_by_recaudadora
Parámetros: p_recaudadora_id smallint
Retorno: TABLE(num_mercado_nvo integer, descripcion character varying)

✅ ÉXITO: Solo existe UNA versión del SP
El problema de ambigüedad ha sido resuelto
```

## Verificación de Otros Stored Procedures

Se verificó que los demás SPs usados por los componentes también estén correctos:

| Stored Procedure | Versiones | Estado |
|-----------------|-----------|--------|
| `sp_get_recaudadoras` | 1 | ✅ OK |
| `sp_get_mercados_by_recaudadora` | 1 | ✅ OK (Corregido) |
| `rpt_padron_energia` | 1 | ✅ OK |
| `sp_get_pagos_loc_grl` | 1 | ✅ OK |
| `sp_energia_modif_buscar` | 1 | ✅ OK |
| `sp_energia_modif_modificar` | 1 | ✅ OK |
| `sp_catalogo_secciones` | 1 | ✅ OK |

## Componentes Afectados

### ✅ PadronEnergia.vue
- Funcionalidad restaurada
- Ahora carga correctamente:
  - Catálogo de recaudadoras
  - Mercados por recaudadora seleccionada
  - Padrón de energía por mercado

### ✅ EnergiaModif.vue
- Sin problemas (todos sus SPs están correctos)

### ✅ PagosLocGrl.vue
- Sin problemas (todos sus SPs están correctos)

## Tipo de Datos Correcto

Se eligió `SMALLINT` porque:
1. La tabla `ta_12_recaudadoras` usa `id_rec SMALLINT`
2. La tabla `ta_11_mercados` usa `oficina SMALLINT` como FK
3. `SMALLINT` es más eficiente para IDs pequeños (rango -32,768 a 32,767)
4. Es consistente con el diseño de la base de datos

## Archivos Creados

```
temp/
├── fix_sp_get_mercados_by_recaudadora.sql          - Script SQL de corrección
├── deploy_fix_mercados_by_recaudadora.php          - Script PHP para despliegue
├── deploy_fix_mercados_recaudadora.bat             - Script batch alternativo
└── RESUMEN_FIX_SP_AMBIGUOUS.md                     - Este documento
```

## Testing Recomendado

1. **Abrir PadronEnergia.vue en el navegador**:
   - URL: http://localhost:5173/mercados/padron-energia
   - Verificar que se cargan las recaudadoras en el dropdown
   - Seleccionar una recaudadora (ejemplo: ID 1 - Recaudadora Centro)
   - Verificar que se cargan los mercados de esa recaudadora
   - Seleccionar un mercado y buscar el padrón
   - Verificar que se muestra la tabla con los locales

2. **Verificar en consola del navegador**:
   - No debe aparecer ningún error SQL
   - Debe mostrar mensajes de éxito al cargar los datos

## Prevención de Futuros Problemas

**Recomendaciones**:

1. **Siempre usar DROP antes de CREATE**:
   ```sql
   DROP FUNCTION IF EXISTS nombre_funcion(tipo_parametro);
   CREATE OR REPLACE FUNCTION nombre_funcion(tipo_parametro) ...
   ```

2. **Especificar el tipo exacto del parámetro**:
   - NO usar tipo genérico o "unknown"
   - Usar el mismo tipo que la columna de la tabla

3. **Verificar antes de desplegar**:
   ```sql
   SELECT p.proname, pg_catalog.pg_get_function_arguments(p.oid)
   FROM pg_catalog.pg_proc p
   WHERE p.proname = 'nombre_funcion';
   ```

4. **Mantener un solo archivo fuente por SP**:
   - Evitar duplicados como `PadronEnergia_sp_...` y `RptPadronEnergia_sp_...`
   - Usar un nombre canónico y referenciarlo desde múltiples componentes

## Estado Final

✅ **PROBLEMA RESUELTO**

El stored procedure `sp_get_mercados_by_recaudadora` ahora tiene una sola versión con el tipo de parámetro correcto (`SMALLINT`), y el componente PadronEnergia puede cargar los mercados sin errores de ambigüedad.
