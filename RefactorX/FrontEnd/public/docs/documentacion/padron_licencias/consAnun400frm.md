# Documentación Técnica: consAnun400frm

## Análisis Técnico

# Documentación Técnica: Migración de Formulario consAnun400frm a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General

- **Backend:** Laravel (PHP) + PostgreSQL
- **Frontend:** Vue.js SPA (Single Page Application)
- **API:** Endpoint único `/api/execute` que recibe un objeto `eRequest` y parámetros, y retorna un objeto `eResponse`.
- **Base de datos:** PostgreSQL, con lógica de consulta encapsulada en stored procedures.

## 2. API Unificada

- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": "getAnuncio400", // o "getPagosAnuncio400"
    "params": { "anuncio": 123 } // o { "numanu": 123 }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": [ ... ],
      "error": null
    }
  }
  ```

## 3. Stored Procedures

- Toda la lógica SQL se encapsula en funciones de PostgreSQL:
  - `sp_get_anuncio_400(anuncio_in integer)`
  - `sp_get_pagos_anun_400(numanu_in integer)`

## 4. Laravel Controller

- El controlador `ExecuteController` recibe la petición, identifica el `eRequest`, valida parámetros, ejecuta el stored procedure correspondiente y retorna el resultado en el formato `eResponse`.
- Los errores se devuelven en el campo `error` de `eResponse`.

## 5. Vue.js Componentes

- Cada formulario/tab de Delphi es una página Vue.js independiente.
- El componente presentado es para la consulta de datos del anuncio.
- El componente de pagos sería similar, accediendo a `/anuncio400/:anuncio/pagos` y usando `getPagosAnuncio400`.
- Navegación mediante breadcrumbs.
- El usuario ingresa el número de anuncio y obtiene los datos.
- Botón para navegar a la página de pagos del anuncio.

## 6. Seguridad

- Validación de parámetros en backend.
- No se exponen consultas SQL directas al frontend.
- Se recomienda proteger el endpoint con autenticación según el contexto de la aplicación.

## 7. Pruebas y Casos de Uso

- Se proveen casos de uso y escenarios de prueba para asegurar la funcionalidad y robustez del sistema.

## 8. Extensibilidad

- El patrón eRequest/eResponse permite agregar nuevas operaciones sin modificar la estructura del endpoint.
- Los stored procedures pueden evolucionar sin afectar la API.

## 9. Consideraciones de Migración

- Los nombres de campos y lógica se mantienen fieles al formulario Delphi original.
- Se recomienda revisar los tipos de datos y normalización en la base de datos destino.

## 10. Despliegue

- Registrar el endpoint en `routes/api.php`:
  ```php
  Route::post('/execute', [\App\Http\Controllers\Api\ExecuteController::class, 'execute']);
  ```
- Asegurar que los stored procedures estén creados en la base de datos PostgreSQL.
- Integrar el componente Vue.js en el router de la SPA.

## Casos de Prueba

## Casos de Prueba para consAnun400frm

### Caso 1: Consulta exitosa de anuncio existente
- **Entrada:** { "eRequest": "getAnuncio400", "params": { "anuncio": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.data contiene los datos del anuncio, eResponse.error = null

### Caso 2: Consulta de pagos de anuncio existente
- **Entrada:** { "eRequest": "getPagosAnuncio400", "params": { "numanu": 12345 } }
- **Esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, eResponse.error = null

### Caso 3: Consulta de anuncio inexistente
- **Entrada:** { "eRequest": "getAnuncio400", "params": { "anuncio": 999999 } }
- **Esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

### Caso 4: Consulta de pagos de anuncio inexistente
- **Entrada:** { "eRequest": "getPagosAnuncio400", "params": { "numanu": 999999 } }
- **Esperado:** eResponse.success = true, eResponse.data = [], eResponse.error = null

### Caso 5: Parámetro faltante
- **Entrada:** { "eRequest": "getAnuncio400", "params": { } }
- **Esperado:** eResponse.success = false, eResponse.error contiene mensaje de parámetro requerido

### Caso 6: eRequest no soportado
- **Entrada:** { "eRequest": "unknownRequest", "params": { } }
- **Esperado:** eResponse.success = false, eResponse.error contiene mensaje de eRequest no soportado

## Casos de Uso

# Casos de Uso - consAnun400frm

**Categoría:** Form

## Caso de Uso 1: Consulta de datos de un anuncio existente

**Descripción:** El usuario ingresa el número de un anuncio válido y consulta todos los datos asociados.

**Precondiciones:**
El anuncio debe existir en la tabla anuncio_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de anuncios.
2. Ingresa el número de anuncio (por ejemplo, 12345).
3. Presiona el botón 'Buscar'.
4. El sistema consulta el backend vía /api/execute con eRequest 'getAnuncio400'.
5. El backend ejecuta el stored procedure y retorna los datos.
6. El frontend muestra todos los campos del anuncio.

**Resultado esperado:**
Se muestran todos los datos del anuncio solicitado, sin errores.

**Datos de prueba:**
{ "anuncio": 12345 }

---

## Caso de Uso 2: Consulta de pagos asociados a un anuncio

**Descripción:** El usuario navega a la página de pagos de un anuncio y visualiza el historial de pagos.

**Precondiciones:**
El anuncio debe existir y tener pagos registrados en pago_anun_400.

**Pasos a seguir:**
1. El usuario consulta un anuncio y hace clic en 'Ver Pagos'.
2. El sistema navega a la página de pagos del anuncio.
3. El frontend solicita los pagos vía /api/execute con eRequest 'getPagosAnuncio400'.
4. El backend ejecuta el stored procedure y retorna los pagos.
5. El frontend muestra la tabla de pagos.

**Resultado esperado:**
Se muestra la lista de pagos asociados al anuncio.

**Datos de prueba:**
{ "numanu": 12345 }

---

## Caso de Uso 3: Manejo de error: anuncio inexistente

**Descripción:** El usuario ingresa un número de anuncio que no existe en la base de datos.

**Precondiciones:**
El número de anuncio no debe existir en anuncio_400.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de anuncios.
2. Ingresa un número de anuncio inexistente (por ejemplo, 999999).
3. Presiona 'Buscar'.
4. El sistema consulta el backend vía /api/execute.
5. El backend retorna un arreglo vacío o error.
6. El frontend muestra un mensaje de error.

**Resultado esperado:**
Se muestra un mensaje indicando que el anuncio no existe.

**Datos de prueba:**
{ "anuncio": 999999 }

---
