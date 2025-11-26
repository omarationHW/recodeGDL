# Solución: Select de Ejecutores no carga en ActualizaFechaEmpresas.vue

## Problema Identificado

El SP `recaudadora_get_ejecutores` **no estaba implementado** - era solo un placeholder que devolvía un mensaje "pendiente de implementación".

## Solución Aplicada

### 1. SP Implementado ✅

**Archivo:** `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql`

El SP ahora:
- Consulta `catastro_gdl.ejecutor`
- Devuelve `cveejecutor` y `empresa`
- Ordena por `cveejecutor`
- Maneja errores correctamente

### 2. Frontend Mejorado ✅

**Archivo:** `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ActualizaFechaEmpresas.vue`

Mejoras:
- Logging detallado en consola
- Alerta al usuario si no hay ejecutores
- Mejor manejo de errores

## Cómo Desplegar

### Opción 1: Usando psql

```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql
```

### Opción 2: Copiar y pegar en pgAdmin

1. Abre pgAdmin
2. Conéctate a `padron_licencias`
3. Abre el Query Tool
4. Copia el contenido de `recaudadora_get_ejecutores.sql`
5. Ejecuta (F5)

### Opción 3: Usar el script PHP (si tienes acceso a la red)

```bash
php temp/deploy_get_ejecutores.php
```

## Verificación

### 1. Probar el SP Directamente

```sql
-- Ver si el SP existe
SELECT proname FROM pg_proc WHERE proname = 'recaudadora_get_ejecutores';

-- Ejecutar el SP
SELECT * FROM recaudadora_get_ejecutores();
```

Resultado esperado: Lista de ejecutores con columnas `cveejecutor` y `empresa`.

### 2. Probar vía API

```bash
curl -X POST http://127.0.0.1:8000/api/generic \
  -H 'Content-Type: application/json' \
  -d '{
    "eRequest": {
      "Operacion": "RECAUDADORA_GET_EJECUTORES",
      "Base": "multas_reglamentos",
      "Parametros": [],
      "Tenant": ""
    }
  }'
```

Resultado esperado: JSON con array de ejecutores en `eResponse.data.result`.

### 3. Probar en el Frontend

1. Abre: http://localhost:3000/multas_reglamentos/actualiza-fecha-empresas
2. Abre DevTools (F12) → Console
3. Verás:
```
🔍 Cargando ejecutores...
📦 Respuesta ejecutores: {result: Array(N), ...}
✅ Ejecutores cargados: N
```

4. El select de "Ejecutor" debe mostrar las opciones

## Estructura del SP

```sql
CREATE OR REPLACE FUNCTION recaudadora_get_ejecutores()
RETURNS TABLE (
  cveejecutor SMALLINT,
  empresa TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.cveejecutor,
    COALESCE(e.empresa, 'Ejecutor ' || e.cveejecutor::TEXT) AS empresa
  FROM catastro_gdl.ejecutor e
  ORDER BY e.cveejecutor;
END;
$$;
```

## Tabla de Origen

- **Tabla:** `catastro_gdl.ejecutor`
- **Campos usados:**
  - `cveejecutor` (SMALLINT) - ID del ejecutor
  - `empresa` (TEXT) - Nombre de la empresa

## Troubleshooting

### ❌ Select vacío pero sin error

**Causa:** No hay ejecutores en la tabla o el SP no devuelve datos.

**Solución:**
```sql
-- Verificar cuántos ejecutores hay
SELECT COUNT(*) FROM catastro_gdl.ejecutor;

-- Ver algunos ejemplos
SELECT * FROM catastro_gdl.ejecutor LIMIT 5;
```

### ❌ Error: "SP no existe"

**Causa:** El SP no está desplegado en la base de datos.

**Solución:** Ejecutar el archivo SQL usando una de las opciones de despliegue arriba.

### ❌ Error en consola: "Error al cargar ejecutores"

**Causa:** El SP no está desplegado o hay un error en el SP.

**Solución:**
1. Abrir DevTools → Console
2. Ver el mensaje de error específico
3. Verificar que el SP existe y funciona con las consultas SQL arriba

## Archivos Modificados

- ✅ `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_get_ejecutores.sql`
- ✅ `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ActualizaFechaEmpresas.vue`

## Archivos de Ayuda Creados

- `temp/deploy_get_ejecutores.php` - Script para desplegar el SP
- `temp/test_get_ejecutores.php` - Script para probar el SP
- `temp/buscar_tabla_ejecutores.php` - Script para buscar tablas relacionadas
- `temp/SOLUCION_EJECUTORES.md` - Este documento

---

**Fecha:** 2025-11-24
**Módulo:** multas_reglamentos
**Componente:** ActualizaFechaEmpresas.vue
