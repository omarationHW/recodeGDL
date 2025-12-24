# Documentación: ReqTrans

## Análisis Técnico

# Documentación Técnica: Migración Formulario ReqTrans (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel 10+ (PHP 8), API RESTful, endpoint único `/api/execute`.
- **Frontend**: Vue.js 3 SPA, cada formulario es una página independiente (NO tabs).
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **Patrón de integración**: eRequest/eResponse (entrada y salida JSON).

## Endpoint Unificado
- **Ruta**: `/api/execute`
- **Método**: POST
- **Entrada**: `{ "eRequest": { "action": "list|show|create|update|delete|catalog|folio|folio_data", ...params } }`
- **Salida**: `{ "eResponse": { ... } }`

## Controlador Laravel
- Un solo controlador (`ReqTransController`) maneja todas las acciones.
- Cada acción del frontend se traduce en un `action` en el JSON de entrada.
- El controlador invoca los stored procedures según la acción.
- Validación de datos con Laravel Validator.
- Manejo de errores y respuestas unificadas.

## Stored Procedures PostgreSQL
- Toda la lógica de negocio (alta, edición, baja, catálogos, consulta de folios) está en funciones/procedimientos almacenados.
- Los procedimientos devuelven datos o booleanos según corresponda.
- Se recomienda usar transacciones para operaciones críticas.

## Componente Vue.js
- Página independiente para ReqTrans.
- Formulario de captura con validación básica.
- Consulta de ejecutores vía API.
- Búsqueda de requerimientos por folio.
- Presentación de resultados y catálogo.
- Navegación y UX amigable.

## Seguridad
- Autenticación recomendada vía JWT o Laravel Sanctum.
- Validación de roles/usuarios para acciones críticas.
- Sanitización de entrada y salida.

## Consideraciones de Migración
- Los combos y catálogos Delphi se migran a catálogos vía API.
- Los cálculos de totales y validaciones de fechas se hacen en el frontend y/o backend según corresponda.
- Los triggers Delphi se migran a lógica en SPs o validaciones en backend.

## Flujo de Datos
1. El usuario accede a la página de ReqTrans.
2. El frontend carga el catálogo de ejecutores vía `/api/execute` con `action: catalog`.
3. El usuario captura los datos y guarda (POST a `/api/execute` con `action: create`).
4. El backend ejecuta el SP correspondiente y responde con el resultado.
5. Para búsquedas, el frontend envía `action: list` o `action: show`.

## Ejemplo de Request/Response
### Crear:
```json
POST /api/execute
{
  "eRequest": {
    "action": "create",
    "folioreq": 1234,
    "tipo": "N",
    ...
  }
}
```

### Respuesta:
```json
{
  "eResponse": {
    "success": true,
    "message": "Registro creado",
    "id": 55
  }
}
```

## Validaciones
- Fechas no pueden ser futuras.
- Importe, recargos, multas, gastos >= 0.
- Folio debe existir en transmisión.
- Usuario debe estar autenticado.

## Notas
- El endpoint `/api/execute` puede ser extendido para otras acciones y catálogos.
- Los stored procedures pueden ser versionados y auditados.
- El frontend puede ser extendido para otros formularios siguiendo el mismo patrón.

## Casos de Uso

# Casos de Uso - ReqTrans

**Categoría:** Form

## Caso de Uso 1: Captura de nuevo requerimiento de transmisión patrimonial

**Descripción:** Un usuario autorizado ingresa un nuevo requerimiento de transmisión patrimonial usando el formulario web.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura. El catálogo de ejecutores está cargado.

**Pasos a seguir:**
- El usuario accede a la página de 'Captura Requerimientos Transmisiones Patrimoniales'.
- Llena todos los campos obligatorios del formulario.
- Presiona 'Guardar'.
- El sistema valida los datos y envía la petición al endpoint `/api/execute` con action 'create'.
- El backend ejecuta el stored procedure de alta y responde con el id generado.

**Resultado esperado:**
El registro es guardado correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "folioreq": 20240001,
  "tipo": "N",
  "cvecta": 123456,
  "cveejec": 12,
  "fecemi": "2024-06-10",
  "importe": 1000.00,
  "recargos": 50.00,
  "multas_ex": 0.00,
  "multas_otr": 0.00,
  "gastos": 100.00,
  "gastos_req": 0.00,
  "total": 1150.00,
  "observ": "Test requerimiento",
  "usu_act": "admin"
}

---

## Caso de Uso 2: Consulta de requerimiento por folio

**Descripción:** Un usuario consulta los datos de un requerimiento de transmisión patrimonial existente por folio.

**Precondiciones:**
El requerimiento existe en la base de datos.

**Pasos a seguir:**
- El usuario accede a la página y utiliza el buscador de folio.
- Ingresa el número de folio y presiona 'Buscar'.
- El sistema envía la petición al endpoint `/api/execute` con action 'list'.
- El backend devuelve los datos del requerimiento.

**Resultado esperado:**
Se muestran los datos del requerimiento correspondiente al folio.

**Datos de prueba:**
{ "folio": 20240001 }

---

## Caso de Uso 3: Actualización de requerimiento existente

**Descripción:** Un usuario autorizado actualiza los datos de un requerimiento de transmisión patrimonial.

**Precondiciones:**
El requerimiento existe y el usuario tiene permisos de edición.

**Pasos a seguir:**
- El usuario busca el requerimiento y edita los campos necesarios.
- Presiona 'Guardar'.
- El sistema valida y envía la petición al endpoint `/api/execute` con action 'update'.
- El backend ejecuta el stored procedure de actualización.

**Resultado esperado:**
El registro es actualizado correctamente.

**Datos de prueba:**
{
  "id": 55,
  "folioreq": 20240001,
  "tipo": "R",
  "cvecta": 123456,
  "cveejec": 12,
  "fecemi": "2024-06-11",
  "importe": 1200.00,
  "recargos": 60.00,
  "multas_ex": 0.00,
  "multas_otr": 0.00,
  "gastos": 120.00,
  "gastos_req": 0.00,
  "total": 1280.00,
  "observ": "Actualización de requerimiento",
  "usu_act": "admin"
}

---

## Casos de Prueba

## Casos de Prueba ReqTrans

### 1. Alta exitosa de requerimiento
- **Entrada**: Todos los campos obligatorios completos y válidos
- **Acción**: POST /api/execute { action: 'create', ... }
- **Esperado**: success=true, id devuelto, registro creado en DB

### 2. Alta con campos faltantes
- **Entrada**: Falta 'tipo' o 'cvecta'
- **Acción**: POST /api/execute { action: 'create', ... }
- **Esperado**: success=false, mensaje de error de validación

### 3. Consulta por folio existente
- **Entrada**: folio válido existente
- **Acción**: POST /api/execute { action: 'list', folio: ... }
- **Esperado**: success=true, data con los datos del requerimiento

### 4. Consulta por folio inexistente
- **Entrada**: folio no existente
- **Acción**: POST /api/execute { action: 'list', folio: ... }
- **Esperado**: success=true, data vacía

### 5. Actualización exitosa
- **Entrada**: id existente, datos válidos
- **Acción**: POST /api/execute { action: 'update', ... }
- **Esperado**: success=true, mensaje de éxito

### 6. Eliminación exitosa
- **Entrada**: id existente
- **Acción**: POST /api/execute { action: 'delete', id: ... }
- **Esperado**: success=true, mensaje de éxito

### 7. Catálogo de ejecutores
- **Entrada**: action: 'catalog', table: 'ejecutor'
- **Acción**: POST /api/execute { action: 'catalog', table: 'ejecutor' }
- **Esperado**: success=true, data con lista de ejecutores

### 8. Consulta de datos generales de folio
- **Entrada**: action: 'folio_data', foliotrans: ...
- **Acción**: POST /api/execute { action: 'folio_data', foliotrans: ... }
- **Esperado**: success=true, data con los datos generales

## Integración con Backend

> ⚠️ Pendiente de documentar

