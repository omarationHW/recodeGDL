# GUÍA TÉCNICA DE CORRECCIONES
## Módulo: estacionamiento_publico

**Fecha:** 2025-11-09
**Propósito:** Guía paso a paso para corregir los errores identificados en la integración Vue ↔ PostgreSQL

---

## ÍNDICE DE CORRECCIONES

### Errores Críticos
1. [sp_busca_folios_divadmin](#1-sp_busca_folios_divadmin)
2. [spget_lic_grales (faltante)](#2-spget_lic_grales-faltante)

### Errores Alta Prioridad
3. [sp_get_remesa_detalle_mpio](#3-sp_get_remesa_detalle_mpio)
4. [spubreports_edocta](#4-spubreports_edocta)
5. [sp_sfrm_baja_pub (faltante)](#5-sp_sfrm_baja_pub-faltante)
6. [spubreports (faltante/renombrar)](#6-spubreports-faltanterenombrar)

### Errores Media Prioridad
7. [sp_gen_individual_add](#7-sp_gen_individual_add)
8. [spget_lic_detalles (faltante)](#8-spget_lic_detalles-faltante)
9. [sQRp_relacion_folios_report](#9-sqrp_relacion_folios_report)

### Errores Baja Prioridad
10. [sp_mensaje_show](#10-sp_mensaje_show)
11. [process_valet_file](#11-process_valet_file)

---

## 1. sp_busca_folios_divadmin

**Prioridad:** CRÍTICO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql`
**Error:** `parameter name 'axo' used more than once`
**Componente afectado:** AplicaPagoDivAdminPublicos.vue
**Tiempo estimado:** 15 minutos

### Diagnóstico
El stored procedure tiene el parámetro `axo` declarado dos veces en la firma de la función.

### Pasos de Corrección

1. Abrir el archivo:
```bash
RefactorX/Base/estacionamiento_publico/database/stored-procedures/AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql
```

2. Buscar la línea donde se declara la función (probablemente línea 1-10):
```sql
CREATE OR REPLACE FUNCTION sp_busca_folios_divadmin(
    axo INTEGER,
    folio INTEGER,
    axo INTEGER,  -- ← ELIMINAR ESTA LÍNEA (parámetro duplicado)
    ...
)
```

3. Eliminar la declaración duplicada del parámetro `axo`

4. Guardar el archivo

5. Re-desplegar el SP:
```bash
psql -U usuario -d nombre_bd -f AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql
```

6. Verificar:
```sql
SELECT proname, proargtypes FROM pg_proc WHERE proname = 'sp_busca_folios_divadmin';
```

### Verificación desde Vue
```javascript
// En AplicaPagoDivAdminPublicos.vue
// Llamar al método que usa este SP
// Verificar que no hay errores de ejecución
```

---

## 2. spget_lic_grales (faltante)

**Prioridad:** CRÍTICO
**Archivo:** Crear `RefactorX/Base/estacionamiento_publico/database/stored-procedures/spget_lic_grales.sql`
**Error:** SP no existe en la base de datos
**Componente afectado:** ConsultaPublicos.vue
**Tiempo estimado:** 2-4 horas

### Diagnóstico
El componente ConsultaPublicos.vue llama a `spget_lic_grales` en la línea 328, pero este SP no existe en la base de datos.

### Análisis Requerido

1. Revisar el código Vue para entender qué parámetros envía:
```bash
# Buscar en ConsultaPublicos.vue línea 328
grep -n "spget_lic_grales" RefactorX/FrontEnd/src/views/modules/estacionamiento_publico/ConsultaPublicos.vue
```

2. Identificar qué datos espera recibir el componente Vue como respuesta

3. Verificar si existe algún SP similar en otros módulos que pueda servir de base

### Estructura Sugerida

```sql
-- RefactorX/Base/estacionamiento_publico/database/stored-procedures/spget_lic_grales.sql

CREATE OR REPLACE FUNCTION spget_lic_grales(
    -- Parámetros a definir según uso en Vue
    p_param1 VARCHAR DEFAULT NULL,
    p_param2 INTEGER DEFAULT NULL
)
RETURNS TABLE (
    -- Columnas a definir según lo que espera Vue
    id INTEGER,
    descripcion VARCHAR,
    -- ... más columnas
) AS $$
BEGIN
    -- Lógica a desarrollar
    RETURN QUERY
    SELECT
        -- Implementar consulta
    FROM tabla_licencias
    WHERE -- Condiciones
    ;
END;
$$ LANGUAGE plpgsql;
```

### Pasos de Implementación

1. Analizar el código Vue para determinar:
   - Parámetros de entrada
   - Estructura de datos de salida
   - Lógica de negocio requerida

2. Diseñar el SP basándose en el análisis

3. Implementar el SP

4. Probar el SP directamente en PostgreSQL

5. Integrar con Vue y probar

### Recomendación
Consultar con el equipo de negocio o revisar el sistema legacy para entender la lógica de "licencias generales" antes de implementar.

---

## 3. sp_get_remesa_detalle_mpio

**Prioridad:** ALTO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/ConsRemesas_sp_get_remesa_detalle_mpio.sql`
**Error:** `type 'ta14_datos_mpio' does not exist`
**Componente afectado:** ConsRemesasPublicos.vue
**Tiempo estimado:** 1-2 horas

### Diagnóstico
El SP intenta usar un tipo de dato personalizado `ta14_datos_mpio` que no existe en la base de datos.

### Opción 1: Crear el tipo faltante

```sql
-- Crear el tipo ta14_datos_mpio
CREATE TYPE ta14_datos_mpio AS (
    -- Definir campos del tipo
    campo1 VARCHAR,
    campo2 INTEGER,
    -- ... más campos según necesidad
);
```

### Opción 2: Modificar el SP para no usar el tipo

1. Abrir el archivo y buscar dónde se usa `ta14_datos_mpio`

2. Reemplazar por:
```sql
-- En lugar de:
RETURNS ta14_datos_mpio

-- Usar:
RETURNS TABLE (
    campo1 VARCHAR,
    campo2 INTEGER,
    -- ... definir campos explícitamente
)
```

### Verificar tipo similar

```sql
-- Buscar si existe tipo similar para estado
SELECT typname FROM pg_type WHERE typname LIKE '%datos%';
```

Posiblemente existe `ta14_datos_edo` y se puede usar como referencia.

### Pasos Recomendados

1. Revisar si existe `ta14_datos_edo`:
```sql
\dT ta14_datos_edo
```

2. Si existe, crear `ta14_datos_mpio` con estructura similar

3. Re-desplegar el SP

4. Probar desde Vue

---

## 4. spubreports_edocta

**Prioridad:** ALTO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/spubreports_spubreports_edocta.sql`
**Error:** `parameter name 'numesta' used more than once`
**Componente afectado:** EdoCtaPublicos.vue
**Tiempo estimado:** 15 minutos

### Diagnóstico
Similar al error #1, hay un parámetro duplicado.

### Pasos de Corrección

1. Abrir el archivo

2. Buscar la declaración de función:
```sql
CREATE OR REPLACE FUNCTION spubreports_edocta(
    numesta INTEGER,
    fecha_inicio DATE,
    numesta INTEGER,  -- ← ELIMINAR
    ...
)
```

3. Eliminar la declaración duplicada

4. Re-desplegar

5. Verificar desde Vue

---

## 5. sp_sfrm_baja_pub (faltante)

**Prioridad:** ALTO
**Archivo:** Crear `RefactorX/Base/estacionamiento_publico/database/stored-procedures/sfrm_baja_pub.sql`
**Error:** SP no existe
**Componente afectado:** BajasPublicos.vue
**Tiempo estimado:** 2-3 horas

### Diagnóstico
SP para proceso de bajas de estacionamientos públicos no existe.

### Análisis Requerido

1. Revisar BajasPublicos.vue línea 42 para ver qué parámetros envía

2. Verificar si existe SP similar (como `sppubbaja` que sí existe)

3. Posiblemente solo necesita renombrarse

### Verificación

```sql
-- Buscar SPs similares
SELECT proname FROM pg_proc WHERE proname LIKE '%baja%';
```

### Posible Solución Simple

Si `sppubbaja` es el SP correcto, crear un alias:

```sql
CREATE OR REPLACE FUNCTION sp_sfrm_baja_pub(
    -- Mismos parámetros que sppubbaja
)
RETURNS VOID AS $$
BEGIN
    -- Llamar al SP real
    PERFORM sppubbaja($1, $2, ...);
END;
$$ LANGUAGE plpgsql;
```

---

## 6. spubreports (faltante/renombrar)

**Prioridad:** ALTO
**Archivos:** Modificar llamadas en Vue o crear alias
**Error:** Vue llama `spubreports` pero existe `spubreports_list`
**Componentes afectados:** PagosPublicos.vue, ReportesPublicos.vue
**Tiempo estimado:** 30 minutos - 1 hora

### Diagnóstico
Existe `spubreports_list` en BD pero Vue llama `spubreports`.

### Opción 1: Crear Alias en BD (Recomendado)

```sql
-- RefactorX/Base/estacionamiento_publico/database/stored-procedures/spubreports_alias.sql

CREATE OR REPLACE FUNCTION spubreports(
    -- Mismos parámetros que spubreports_list
    p_param1 VARCHAR,
    p_param2 DATE
)
RETURNS TABLE (
    -- Misma estructura que spubreports_list
) AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM spubreports_list($1, $2);
END;
$$ LANGUAGE plpgsql;
```

### Opción 2: Modificar Vue

En PagosPublicos.vue y ReportesPublicos.vue, cambiar:

```javascript
// De:
const result = await apiService.call('spubreports', params);

// A:
const result = await apiService.call('spubreports_list', params);
```

### Recomendación
Usar Opción 1 (alias) para mantener compatibilidad y no modificar código Vue.

---

## 7. sp_gen_individual_add

**Prioridad:** MEDIO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/Gen_Individual_sp_gen_individual_add.sql`
**Error:** `RETURN NEXT cannot have a parameter in function with OUT parameters`
**Componente afectado:** GenIndividualPublicos.vue
**Tiempo estimado:** 1 hora

### Diagnóstico
El SP usa parámetros OUT y también intenta usar RETURN NEXT con parámetros explícitos.

### Error Típico

```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    OUT resultado INTEGER,
    OUT mensaje VARCHAR
) AS $$
BEGIN
    -- ...
    RETURN NEXT (123, 'mensaje');  -- ← ERROR
END;
```

### Corrección

```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    OUT resultado INTEGER,
    OUT mensaje VARCHAR
) AS $$
BEGIN
    -- Opción 1: Asignar valores a OUT parameters
    resultado := 123;
    mensaje := 'mensaje';
    RETURN NEXT;  -- Sin parámetros

    -- Opción 2: Cambiar a RETURNS TABLE
    -- Ver abajo
END;
```

### Opción Alternativa: Cambiar a RETURNS TABLE

```sql
CREATE OR REPLACE FUNCTION sp_gen_individual_add(
    p_param1 INTEGER
)
RETURNS TABLE (
    resultado INTEGER,
    mensaje VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 123, 'mensaje'::VARCHAR;
END;
```

### Pasos

1. Abrir el archivo
2. Revisar línea 80 donde ocurre el error
3. Decidir entre Opción 1 o 2
4. Implementar corrección
5. Re-desplegar
6. Probar

---

## 8. spget_lic_detalles (faltante)

**Prioridad:** MEDIO
**Archivo:** Crear nuevo
**Error:** SP no existe
**Componente afectado:** ReportesPublicos.vue
**Tiempo estimado:** 2 horas

### Diagnóstico
Similar a #2 (spget_lic_grales), necesita análisis y desarrollo.

### Posible Relación
Podría estar relacionado con `spget_lic_grales`. Revisar si hay lógica compartida.

### Pasos

1. Analizar uso en ReportesPublicos.vue línea 87
2. Determinar si es reporte detallado de licencias
3. Verificar si existe SP similar en otros módulos
4. Implementar basándose en análisis

---

## 9. sQRp_relacion_folios_report

**Prioridad:** MEDIO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/sQRp_relacion_folios_sQRp_relacion_folios_report.sql`
**Error:** SP se despliega exitosamente pero no se encuentra después
**Componentes afectados:** RelacionFoliosPublicos.vue, SolicRepFoliosPublicos.vue
**Tiempo estimado:** 1 hora

### Diagnóstico
Posible problema de nombre (case sensitivity) o esquema incorrecto.

### Verificación

```sql
-- Buscar el SP con diferentes variantes
SELECT proname FROM pg_proc WHERE proname ILIKE '%relacion_folios%';

-- Verificar esquema
SELECT n.nspname, p.proname
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname LIKE '%relacion%';
```

### Posibles Causas

1. **Nombre con mayúsculas/minúsculas**: PostgreSQL es case-sensitive con nombres entrecomillados
2. **Esquema incorrecto**: Podría estar creándose en esquema diferente al esperado
3. **Tipo en lugar de función**: Podría estar creando un tipo en lugar de función

### Soluciones

#### Si es problema de case:

```sql
-- Crear versión sin comillas (lowercase)
CREATE OR REPLACE FUNCTION sqrp_relacion_folios_report(...)  -- todo minúsculas

-- O crear alias
CREATE OR REPLACE FUNCTION sqrp_relacion_folios_report(...)
AS $$ SELECT * FROM "sQRp_relacion_folios_report"(...); $$;
```

#### Si es problema de esquema:

```sql
-- Asegurar que se crea en esquema público
CREATE OR REPLACE FUNCTION public.sqrp_relacion_folios_report(...)
```

---

## 10. sp_mensaje_show

**Prioridad:** BAJO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/mensaje_sp_mensaje_show.sql`
**Error:** `parameter name 'tipo' used more than once`
**Componente afectado:** MensajePublicos.vue
**Tiempo estimado:** 15 minutos

### Diagnóstico
Parámetro duplicado. Mismo tipo de error que #1 y #4.

### Pasos

1. Abrir archivo
2. Buscar parámetro `tipo` duplicado
3. Eliminar duplicado
4. Re-desplegar
5. Verificar

---

## 11. process_valet_file

**Prioridad:** BAJO
**Archivo:** `RefactorX/Base/estacionamiento_publico/database/stored-procedures/sfrm_valet_paso_process_valet_file.sql`
**Error:** `RETURN NEXT cannot have a parameter in function with OUT parameters`
**Componente afectado:** ValetPasoPublicos.vue
**Tiempo estimado:** 1 hora

### Diagnóstico
Mismo tipo de error que #7 (sp_gen_individual_add).

### Corrección

Revisar línea 33 donde ocurre el error:

```sql
-- Error:
RETURN NEXT (v_row, 'OK', 'Insertado');

-- Corrección 1: Con OUT parameters
-- Asignar valores a variables OUT antes de RETURN NEXT
out_row := v_row;
out_status := 'OK';
out_message := 'Insertado';
RETURN NEXT;

-- Corrección 2: Cambiar a RETURNS TABLE
RETURNS TABLE (
    row_num INTEGER,
    status VARCHAR,
    message VARCHAR
)
```

---

## CHECKLIST DE VERIFICACIÓN POST-CORRECCIÓN

Después de cada corrección, seguir este checklist:

### 1. Verificación en PostgreSQL

```sql
-- Verificar que el SP existe
\df nombre_del_sp

-- Verificar parámetros
\df+ nombre_del_sp

-- Probar ejecución básica
SELECT * FROM nombre_del_sp(param1, param2);
```

### 2. Verificación en Código

```bash
# Buscar todas las referencias al SP
grep -r "nombre_del_sp" RefactorX/FrontEnd/src/
```

### 3. Prueba desde Vue

1. Levantar servidor de desarrollo
2. Navegar al componente afectado
3. Ejecutar la funcionalidad que usa el SP
4. Verificar en console del navegador que no hay errores
5. Verificar que los datos se muestran correctamente

### 4. Documentación

Actualizar documentación con:
- Fecha de corrección
- Cambios realizados
- Parámetros del SP
- Ejemplo de uso

---

## SCRIPTS DE AYUDA

### Script para re-desplegar múltiples SPs

```bash
#!/bin/bash
# redeploy-sps.sh

PSQL="psql -U usuario -d nombre_bd"
SP_DIR="RefactorX/Base/estacionamiento_publico/database/stored-procedures"

# Lista de SPs a re-desplegar
SPS=(
    "AplicaPgo_DivAdmin_sp_busca_folios_divadmin.sql"
    "spubreports_spubreports_edocta.sql"
    "mensaje_sp_mensaje_show.sql"
)

for sp in "${SPS[@]}"; do
    echo "Desplegando $sp..."
    $PSQL -f "$SP_DIR/$sp"
    if [ $? -eq 0 ]; then
        echo "✓ $sp desplegado exitosamente"
    else
        echo "✗ Error al desplegar $sp"
    fi
done
```

### Script para verificar SPs

```bash
#!/bin/bash
# verify-sps.sh

PSQL="psql -U usuario -d nombre_bd -t -c"

# SPs críticos que deben existir
CRITICAL_SPS=(
    "sp_busca_folios_divadmin"
    "spget_lic_grales"
    "sp_get_remesa_detalle_mpio"
    "spubreports_edocta"
)

echo "Verificando SPs críticos..."
for sp in "${CRITICAL_SPS[@]}"; do
    COUNT=$($PSQL "SELECT COUNT(*) FROM pg_proc WHERE proname='$sp'")
    if [ $COUNT -eq 0 ]; then
        echo "✗ FALTA: $sp"
    else
        echo "✓ OK: $sp"
    fi
done
```

---

## CONTACTOS Y RECURSOS

### Documentación
- PostgreSQL Functions: https://www.postgresql.org/docs/current/sql-createfunction.html
- PL/pgSQL: https://www.postgresql.org/docs/current/plpgsql.html

### Revisar Código Legacy
Si existe sistema anterior en Delphi/PHP, revisar lógica original de SPs faltantes.

### Base de Conocimiento
Documentar cada corrección en base de conocimiento interna para futuras referencias.

---

**Última actualización:** 2025-11-09
**Autor:** Análisis Automatizado de Integración
**Versión:** 1.0
