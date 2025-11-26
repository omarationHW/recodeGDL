# Solución Completa: Módulo autdescto.vue

## Problema Inicial
El componente `autdescto.vue` mostraba el siguiente error:
```
El Stored Procedure 'recaudadora_autdescto' no existe en el esquema 'public'.
Esquemas disponibles: public. El SP no existe en ningún esquema.
```

Y no traía datos en la tabla.

## Análisis del Problema

### 1. Componente Vue
- **Ubicación**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/autdescto.vue`
- **Problema**: El componente llamaba al SP `recaudadora_autdescto` que no existía en la BD
- **Parámetros incorrectos**: Usaba formato `{ name, type, value }` en lugar de `{ nombre, valor, tipo }`
- **Lectura incorrecta de datos**: Buscaba `data.rows` en lugar de `data.result`

### 2. Stored Procedure
- **Archivo**: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_autdescto.sql`
- **Estado inicial**: Era un placeholder sin implementar
- **Problema**: No estaba desplegado en la base de datos

### 3. Tablas de Base de Datos
- **Tablas necesarias**: `descpred`, `c_descpred`
- **Ubicación real**: Esquema `catastro_gdl`
- **Registros**:
  - `catastro_gdl.descpred`: 1,940,226 registros
  - `catastro_gdl.c_descpred`: 1,289 registros

### 4. Configuración del Backend
- **Problema**: El módulo `multas_reglamentos` estaba configurado para usar la BD `multas_reglamentos`
- **Realidad**: La BD real es `padron_licencias`

## Solución Implementada

### 1. Creación del Stored Procedure

Se implementó el SP `recaudadora_autdescto` con la siguiente estructura:

```sql
DROP FUNCTION IF EXISTS recaudadora_autdescto(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_autdescto(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    cvecuenta INTEGER,
    cvedescuento SMALLINT,
    bimini SMALLINT,
    bimfin SMALLINT,
    fecalta DATE,
    captalta CHARACTER(10),
    fecbaja DATE,
    captbaja CHARACTER(10),
    propie CHARACTER(50),
    solicitante CHARACTER(30),
    observaciones VARCHAR(255),
    recaud SMALLINT,
    foliodesc INTEGER,
    status CHARACTER(1),
    identificacion CHARACTER(20),
    fecnac DATE,
    institucion SMALLINT,
    rfc VARCHAR(13),
    curp VARCHAR(18),
    descripcion CHARACTER(30)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    v_cvecuenta := p_clave_cuenta::INTEGER;

    RETURN QUERY
    SELECT d.cvecuenta, d.cvedescuento, d.bimini, d.bimfin,
           d.fecalta, d.captalta, d.fecbaja, d.captbaja,
           d.propie, d.solicitante, d.observaciones, d.recaud, d.foliodesc,
           d.status, d.identificacion, d.fecnac, d.institucion,
           d.rfc, d.curp, c.descripcion
    FROM catastro_gdl.descpred d
    LEFT JOIN catastro_gdl.c_descpred c ON c.cvedescuento = d.cvedescuento
    WHERE d.cvecuenta = v_cvecuenta
    ORDER BY d.fecalta DESC;

EXCEPTION
    WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'El valor de clave_cuenta debe ser un número válido';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar descuentos: %', SQLERRM;
END;
$$;
```

**Características del SP:**
- Acepta el parámetro `p_clave_cuenta` como VARCHAR
- Convierte la cuenta a INTEGER internamente
- Consulta las tablas en el esquema `catastro_gdl`
- Realiza un LEFT JOIN con la tabla de catálogos `c_descpred`
- Ordena por fecha de alta descendente
- Maneja excepciones apropiadamente

### 2. Despliegue del SP

Script de despliegue: `temp/deploy_recaudadora_autdescto.php`

**Resultado:**
```
✅ SP desplegado correctamente
Schema: public
SP Name: recaudadora_autdescto
Arguments: p_clave_cuenta character varying
```

### 3. Corrección del GenericController

**Archivo**: `RefactorX/BackEnd/app/Http/Controllers/Api/GenericController.php`

**Cambio realizado:**
```php
// ANTES
'multas_reglamentos' => [
    'database' => 'multas_reglamentos',
    'schema' => 'public',
    'allowed_schemas' => ['public']
],

// DESPUÉS
'multas_reglamentos' => [
    'database' => 'padron_licencias',
    'schema' => 'public',
    'allowed_schemas' => ['public', 'comun']
],
```

### 4. Corrección del Componente Vue

**Archivo**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/autdescto.vue`

**Cambios realizados:**

**ANTES:**
```javascript
const params = [
  { name: 'clave_cuenta', type: 'C', value: String(filters.value.cuenta || '') }
]

const data = await execute(OP_LIST, BASE_DB, params)
const arr = Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
```

**DESPUÉS:**
```javascript
const params = [
  { nombre: 'p_clave_cuenta', valor: String(filters.value.cuenta || ''), tipo: 'string' }
]

const data = await execute(OP_LIST, BASE_DB, params)
const arr = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []
```

## Pruebas Realizadas

### 1. Prueba Directa del SP en BD

**Script**: `temp/test_autdescto_final.php`

**Resultado:**
```
✅ SP ejecutado correctamente
Resultados con cuenta 129976: 9 registros
Resultados con cuenta 99999: 0 registros (esperado)
```

### 2. Prueba vía API

**Script**: `temp/test_autdescto_via_api.php`

**Payload de prueba:**
```json
{
  "eRequest": {
    "Operacion": "recaudadora_autdescto",
    "Base": "multas_reglamentos",
    "Esquema": "public",
    "Parametros": [
      {
        "nombre": "p_clave_cuenta",
        "valor": "129976",
        "tipo": "string"
      }
    ]
  }
}
```

**Resultado:**
```json
{
  "eResponse": {
    "success": true,
    "message": "Operación completada exitosamente",
    "data": {
      "result": [...],
      "count": 9
    }
  }
}
```

## Archivos Modificados

1. ✅ `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_autdescto.sql`
   - Implementación completa del SP

2. ✅ `RefactorX/BackEnd/app/Http/Controllers/Api/GenericController.php`
   - Corrección de configuración de módulo `multas_reglamentos`

3. ✅ `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/autdescto.vue`
   - Corrección del formato de parámetros
   - Corrección de lectura de respuesta

## Scripts de Verificación Creados

1. `temp/verificar_autdescto.php` - Verifica existencia del SP en BD
2. `temp/ver_estructura_descpred.php` - Muestra estructura de tablas
3. `temp/verificar_tablas_autdescto.php` - Verifica tablas necesarias
4. `temp/deploy_recaudadora_autdescto.php` - Despliega el SP en BD
5. `temp/test_autdescto_final.php` - Prueba directa del SP
6. `temp/test_autdescto_via_api.php` - Prueba vía API

## Resultado Final

✅ **El módulo autdescto.vue ahora funciona correctamente:**

1. ✅ SP `recaudadora_autdescto` creado e implementado
2. ✅ SP desplegado en la base de datos `padron_licencias`
3. ✅ Referencias de esquema corregidas (`catastro_gdl`)
4. ✅ Configuración del backend corregida
5. ✅ Componente Vue corregido con parámetros correctos
6. ✅ API probada y funcional
7. ✅ Retorna datos correctamente de la tabla `descpred`

## Pasos para Probar en el Frontend

1. Acceder a: http://localhost:3000
2. Navegar al módulo "Autorización de Descuento" (autdescto)
3. Ingresar una cuenta (ejemplo: 129976)
4. Click en "Buscar"
5. Debe mostrar la tabla con los descuentos de esa cuenta

## Notas Técnicas

- El SP busca en el esquema `catastro_gdl` porque es donde están las tablas con datos
- El esquema `public` es donde se crea el SP para que sea accesible desde la API
- La estructura de tipos de datos del RETURNS TABLE debe coincidir exactamente con los tipos reales de las columnas
- El formato de parámetros de la API genérica es: `{ nombre, valor, tipo }`
- La respuesta de la API está en `data.result`, no en `data.rows`

## Fecha de Implementación
2025-11-19

## Estado
✅ COMPLETADO Y FUNCIONAL
