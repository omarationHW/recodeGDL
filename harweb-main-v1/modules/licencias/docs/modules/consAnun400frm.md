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
