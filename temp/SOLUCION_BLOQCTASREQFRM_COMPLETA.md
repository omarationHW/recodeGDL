# Solución Completa: Módulo bloqctasreqfrm.vue

## Problema Inicial

El componente `bloqctasreqfrm.vue` mostraba el siguiente error al hacer clic en el botón Buscar:

```
El Stored Procedure 'recaudadora_bloqctasreqfrm' no existe en el esquema 'public'.
Esquemas disponibles: catastro_gdl, cnx_com, cnx_merca, comun, comunX, db_egresos,
db_gasto2002, db_ingresos, dbestacion, dbingresosvw, informix, informix_migration,
padron_licencias, public, publicX. El SP no existe en ningún esquema.
```

## Mejoras Implementadas Adicionales

Además de solucionar el error del SP, se implementaron las siguientes mejoras en el componente:

1. ✅ **Botón de buscar deshabilitado al inicio**
2. ✅ **Se habilita solo cuando se escriben datos en el campo cuenta**
3. ✅ **Código formateado y más legible**
4. ✅ **Placeholder agregado al input**

## Análisis del Problema

### 1. Componente Vue
- **Ubicación**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/bloqctasreqfrm.vue`
- **Problema inicial**: El componente llamaba al SP `recaudadora_bloqctasreqfrm` que no existía
- **Parámetros incorrectos**: Usaba formato `{ name, type, value }` en lugar de `{ nombre, valor, tipo }`
- **Lectura incorrecta de datos**: Buscaba `data.rows` en lugar de `data.result`
- **Botón siempre habilitado**: No validaba si el campo cuenta tenía datos

### 2. Stored Procedure
- **Archivo**: `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqctasreqfrm.sql`
- **Estado inicial**: Era un placeholder sin implementar
- **Problema**: No estaba desplegado en la base de datos

### 3. Tabla de Base de Datos
- **Tabla necesaria**: `norequeribles`
- **Ubicación real**: Esquema `catastro_gdl`
- **Registros**: 19 registros (bloqueos de cuentas)

## Solución Implementada

### 1. Creación del Stored Procedure

Se implementó el SP `recaudadora_bloqctasreqfrm` con la siguiente estructura:

```sql
DROP FUNCTION IF EXISTS recaudadora_bloqctasreqfrm(VARCHAR);

CREATE OR REPLACE FUNCTION recaudadora_bloqctasreqfrm(
    p_clave_cuenta VARCHAR
)
RETURNS TABLE(
    recaud SMALLINT,
    urbrus CHARACTER(1),
    cuenta INTEGER,
    feccap DATE,
    capturista CHARACTER(10),
    fecbaja DATE,
    user_baja CHARACTER(10),
    observacion TEXT,
    cvecuenta INTEGER,
    tipo_bloq INTEGER,
    fecha_envio DATE,
    lote_envio INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cvecuenta INTEGER;
BEGIN
    v_cvecuenta := p_clave_cuenta::INTEGER;

    RETURN QUERY
    SELECT n.recaud, n.urbrus, n.cuenta, n.feccap, n.capturista,
           n.fecbaja, n.user_baja, n.observacion, n.cvecuenta,
           n.tipo_bloq, n.fecha_envio, n.lote_envio
    FROM catastro_gdl.norequeribles n
    WHERE n.cvecuenta = v_cvecuenta
    ORDER BY n.feccap DESC;

EXCEPTION
    WHEN invalid_text_representation THEN
        RAISE EXCEPTION 'El valor de clave_cuenta debe ser un número válido';
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error al consultar bloqueos: %', SQLERRM;
END;
$$;
```

**Características del SP:**
- Acepta el parámetro `p_clave_cuenta` como VARCHAR
- Convierte la cuenta a INTEGER internamente
- Consulta la tabla `norequeribles` en el esquema `catastro_gdl`
- Ordena por fecha de captura descendente
- Maneja excepciones apropiadamente

### 2. Despliegue del SP

Script de despliegue: `temp/deploy_bloqctasreqfrm.php`

**Resultado:**
```
✅ SP desplegado correctamente
Schema: public
SP Name: recaudadora_bloqctasreqfrm
Arguments: p_clave_cuenta character varying
```

### 3. Corrección del Componente Vue

**Archivo**: `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/bloqctasreqfrm.vue`

**Cambios realizados:**

#### a) Validación del Botón de Buscar

**AGREGADO:**
```javascript
import { ref, computed } from 'vue'

// Computed: habilitar botón Buscar solo si cuenta tiene datos
const isBuscarEnabled = computed(() => {
  return filters.value.cuenta && filters.value.cuenta.trim() !== ''
})
```

**En el template:**
```vue
<button
  class="btn-municipal-primary"
  :disabled="loading || !isBuscarEnabled"
  @click="reload"
>
```

#### b) Corrección de Parámetros y Respuesta

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

#### c) Formato y Legibilidad

- ✅ Código formateado con indentación apropiada
- ✅ Template más legible con saltos de línea
- ✅ Placeholder agregado al input: "Ingresa la cuenta"
- ✅ Eliminada la carga automática al iniciar

## Pruebas Realizadas

### 1. Prueba Directa del SP en BD

**Script**: `temp/deploy_bloqctasreqfrm.php`

**Resultado:**
```
Probando con cuenta: 57748
✅ SP ejecutado correctamente
Resultados: 1 registros
```

### 2. Prueba vía API

**Script**: `temp/test_bloqctasreqfrm_api.php`

**Payload de prueba:**
```json
{
  "eRequest": {
    "Operacion": "recaudadora_bloqctasreqfrm",
    "Base": "multas_reglamentos",
    "Esquema": "public",
    "Parametros": [
      {
        "nombre": "p_clave_cuenta",
        "valor": "57748",
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
      "result": [
        {
          "recaud": 3,
          "urbrus": "U",
          "cuenta": 1411,
          "feccap": "2023-12-11",
          "capturista": "hnavarro  ",
          "fecbaja": "2025-09-30",
          "user_baja": "hnavarro  ",
          "observacion": "SE BLOQUEA CUENTA EN ACATO...",
          "cvecuenta": 57748,
          "tipo_bloq": 200,
          "fecha_envio": null,
          "lote_envio": null
        }
      ],
      "count": 1
    }
  }
}
```

## Archivos Modificados

1. ✅ `RefactorX/Base/multas_reglamentos/database/generated/recaudadora_bloqctasreqfrm.sql`
   - Implementación completa del SP

2. ✅ `RefactorX/FrontEnd/src/views/modules/multas_reglamentos/bloqctasreqfrm.vue`
   - Agregado computed para validar botón de buscar
   - Corrección del formato de parámetros
   - Corrección de lectura de respuesta
   - Mejoras de formato y legibilidad

## Scripts de Verificación Creados

1. `temp/verificar_norequeribles.php` - Verifica estructura de tabla norequeribles
2. `temp/deploy_bloqctasreqfrm.php` - Despliega el SP en BD
3. `temp/test_bloqctasreqfrm_api.php` - Prueba vía API

## Estructura de la Tabla norequeribles

```
recaud: SMALLINT - Recaudadora
urbrus: CHARACTER(1) - Urbana/Rústica
cuenta: INTEGER - Número de cuenta
feccap: DATE - Fecha de captura
capturista: CHARACTER(10) - Usuario que capturó
fecbaja: DATE - Fecha de baja/desbloqueo
user_baja: CHARACTER(10) - Usuario que desbloqueó
observacion: TEXT - Observaciones del bloqueo
cvecuenta: INTEGER - Clave cuenta (principal)
tipo_bloq: INTEGER - Tipo de bloqueo
fecha_envio: DATE - Fecha de envío
lote_envio: INTEGER - Lote de envío
```

## Resultado Final

✅ **El módulo bloqctasreqfrm.vue ahora funciona correctamente:**

1. ✅ SP `recaudadora_bloqctasreqfrm` creado e implementado
2. ✅ SP desplegado en la base de datos `padron_licencias`
3. ✅ Referencias de esquema corregidas (`catastro_gdl`)
4. ✅ Componente Vue corregido con parámetros correctos
5. ✅ API probada y funcional
6. ✅ Retorna datos correctamente de la tabla `norequeribles`
7. ✅ **Botón de buscar con validación implementada**
8. ✅ **UX mejorada con placeholder y formato legible**

## Comportamiento del Botón de Buscar

El botón **Buscar** estará:

- ❌ **Deshabilitado** (gris) cuando:
  - El campo cuenta esté vacío (estado inicial)
  - El campo solo contenga espacios en blanco
  - Se esté ejecutando una búsqueda (loading)

- ✅ **Habilitado** cuando:
  - El campo cuenta contenga al menos un carácter válido

## Pasos para Probar en el Frontend

1. Acceder a: http://localhost:3000
2. Navegar al módulo "Bloqueo Cuentas Requeridas"
3. **Verificar que el botón "Buscar" está deshabilitado**
4. Ingresar una cuenta (ejemplo: **57748** o **273902**)
5. **Observar que el botón se habilita automáticamente**
6. Click en "Buscar"
7. Debe mostrar la tabla con los bloqueos de esa cuenta

## Notas Técnicas

- El SP busca en el esquema `catastro_gdl` porque es donde está la tabla con datos
- El esquema `public` es donde se crea el SP para que sea accesible desde la API
- La estructura de tipos de datos del RETURNS TABLE debe coincidir exactamente con los tipos reales
- El formato de parámetros de la API genérica es: `{ nombre, valor, tipo }`
- La respuesta de la API está en `data.result`, no en `data.rows`
- El botón usa la propiedad computed `isBuscarEnabled` para validarse reactivamente

## Fecha de Implementación
2025-11-19

## Estado
✅ COMPLETADO Y FUNCIONAL CON MEJORAS DE UX
