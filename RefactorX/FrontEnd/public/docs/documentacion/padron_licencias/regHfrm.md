# Documentación Técnica: regHfrm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario regHfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
El formulario `regHfrm` de Delphi muestra y administra los registros históricos de movimientos catastrales (tabla `h_catastro`). La migración implica:
- Backend API en Laravel (controlador único, endpoint `/api/execute`)
- Lógica SQL en stored procedures PostgreSQL
- Frontend como página Vue.js independiente
- Comunicación por eRequest/eResponse

## 2. Arquitectura
- **Backend**: Laravel Controller (`RegHController`) expone un endpoint `/api/execute` que recibe un objeto JSON con `eRequest` y `params`. Cada acción (listar, crear, editar, eliminar) se mapea a un método y a un stored procedure.
- **Frontend**: Componente Vue.js de página completa, sin tabs, con tabla, formularios de alta/edición y navegación breadcrumb.
- **Base de Datos**: PostgreSQL, toda la lógica SQL encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request**:
  ```json
  {
    "eRequest": "get_historic_records",
    "params": { "cvecuenta": 12345 }
  }
  ```
- **Response**:
  ```json
  {
    "success": true,
    "data": [ { "axocomp": 2023, "nocomp": 1 }, ... ],
    "message": ""
  }
  ```

## 4. Stored Procedures
- `sp_get_historic_records(p_cvecuenta)`
- `sp_get_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`
- `sp_create_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`
- `sp_update_historic_record(p_cvecuenta, p_axocomp, p_nocomp, p_new_axocomp, p_new_nocomp)`
- `sp_delete_historic_record(p_cvecuenta, p_axocomp, p_nocomp)`

## 5. Seguridad
- Validación de parámetros en el controlador
- Solo permite operaciones sobre registros históricos de la cuenta indicada
- El endpoint puede protegerse con middleware de autenticación Laravel

## 6. Frontend (Vue.js)
- Página independiente `/reg-historic`
- Tabla con columnas Año (`axocomp`), No. Comp. (`nocomp`), acciones (editar/eliminar)
- Formularios modales para alta y edición
- Breadcrumb para navegación
- Llama a `/api/execute` con eRequest adecuado

## 7. Integración
- El frontend y backend se comunican exclusivamente por `/api/execute` usando el patrón eRequest/eResponse
- El frontend puede ser integrado en un router Vue.js como página independiente

## 8. Consideraciones de Migración
- No se usan tabs ni componentes tabulares; cada formulario es una página
- El formulario es autosuficiente y no depende de otros módulos
- El diseño permite extensión para agregar más campos a futuro

## 9. Ejemplo de Uso
- Para listar registros históricos de la cuenta 12345:
  ```json
  {
    "eRequest": "get_historic_records",
    "params": { "cvecuenta": 12345 }
  }
  ```
- Para crear un registro:
  ```json
  {
    "eRequest": "create_historic_record",
    "params": { "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }
  }
  ```

## 10. Extensión
- Para agregar más campos, modificar los stored procedures y el controlador para aceptar/retornar los nuevos campos.

## 11. Pruebas
- Ver sección de casos de uso y casos de prueba.

## Casos de Prueba

## Casos de Prueba para Registros Históricos (regHfrm)

### 1. Consulta de registros históricos
- **Entrada:** cvecuenta = 12345
- **Acción:** POST /api/execute { eRequest: 'get_historic_records', params: { cvecuenta: 12345 } }
- **Resultado esperado:** Respuesta JSON con success=true y lista de registros históricos (axocomp, nocomp)

### 2. Alta de registro histórico válido
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'create_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2 } }
- **Resultado esperado:** success=true, message='Historic record created', el registro aparece en la consulta

### 3. Alta de registro histórico con datos faltantes
- **Entrada:** cvecuenta = 12345, axocomp = null, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'create_historic_record', params: { cvecuenta: 12345, nocomp: 2 } }
- **Resultado esperado:** success=false, message indica error de validación

### 4. Edición de registro histórico
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2, nuevos valores axocomp=2025, nocomp=3
- **Acción:** POST /api/execute { eRequest: 'update_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2, new_axocomp: 2025, new_nocomp: 3 } }
- **Resultado esperado:** success=true, message='Historic record updated', el registro aparece actualizado

### 5. Eliminación de registro histórico
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'delete_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2 } }
- **Resultado esperado:** success=true, message='Historic record deleted', el registro ya no aparece en la consulta

### 6. Consulta de registro inexistente
- **Entrada:** cvecuenta = 99999, axocomp = 1900, nocomp = 1
- **Acción:** POST /api/execute { eRequest: 'get_historic_record', params: { cvecuenta: 99999, axocomp: 1900, nocomp: 1 } }
- **Resultado esperado:** success=true, data=null

## Casos de Uso

# Casos de Uso - regHfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de registros históricos de una cuenta

**Descripción:** El usuario desea ver todos los movimientos históricos asociados a una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Ingresa el número de cuenta catastral (por ejemplo, 12345).
3. El sistema envía un eRequest 'get_historic_records' con el parámetro cvecuenta.
4. El backend responde con la lista de registros históricos.

**Resultado esperado:**
Se muestra una tabla con los registros históricos (año, número de comprobante) de la cuenta indicada.

**Datos de prueba:**
{ "cvecuenta": 12345 }

---

## Caso de Uso 2: Alta de un nuevo registro histórico

**Descripción:** El usuario agrega un nuevo registro histórico para una cuenta catastral.

**Precondiciones:**
El usuario está autenticado y tiene permisos de escritura.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Hace clic en 'Nuevo Registro Histórico'.
3. Llena los campos Año, No. Comp., Clave Cuenta.
4. Envía el formulario.
5. El sistema envía un eRequest 'create_historic_record' con los datos.
6. El backend inserta el registro y responde con éxito.

**Resultado esperado:**
El nuevo registro aparece en la tabla de registros históricos.

**Datos de prueba:**
{ "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }

---

## Caso de Uso 3: Eliminación de un registro histórico

**Descripción:** El usuario elimina un registro histórico existente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario accede a la página de registros históricos.
2. Ubica el registro a eliminar en la tabla.
3. Hace clic en 'Eliminar'.
4. El sistema solicita confirmación.
5. El usuario confirma.
6. El sistema envía un eRequest 'delete_historic_record' con los identificadores.
7. El backend elimina el registro y responde con éxito.

**Resultado esperado:**
El registro ya no aparece en la tabla.

**Datos de prueba:**
{ "cvecuenta": 12345, "axocomp": 2024, "nocomp": 2 }

---
