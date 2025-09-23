# Documentación Técnica: Migración de Formulario sfrmprediocarto a Laravel + Vue.js + PostgreSQL

## Descripción General
Este módulo corresponde a la migración del formulario Delphi `sfrmprediocarto` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite visualizar la ubicación cartográfica de un predio a partir de su clave catastral.

## Arquitectura
- **Frontend:** Vue.js SPA, componente de página independiente.
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## Flujo de Trabajo
1. El usuario ingresa la clave catastral en el formulario Vue.js y solicita la ubicación.
2. El frontend envía una petición POST a `/api/execute` con el action `getPredioCartoUrl` y la clave catastral.
3. El backend valida la petición y construye la URL del visor cartográfico.
4. El backend responde con la URL generada.
5. El frontend muestra el visor en un iframe embebido.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "getPredioCartoUrl",
      "data": {
        "cvecatastro": "<clave_catastral>"
      }
    }
  }
  ```
- **Response (éxito):**
  ```json
  {
    "eResponse": {
      "success": true,
      "url": "http://192.168.4.20:8080/Visor/index.html#user=123&session=se123&clavePredi0=<clave_catastral>",
      "message": "URL generated successfully"
    }
  }
  ```
- **Response (error):**
  ```json
  {
    "eResponse": {
      "success": false,
      "message": "Missing cvecatastro parameter"
    }
  }
  ```

## Stored Procedure
- **Nombre:** `sp_get_predio_carto_url`
- **Parámetro:** `p_cvecatastro` (TEXT)
- **Retorno:** URL (TEXT)
- **Uso:** Puede ser invocado desde el backend para obtener la URL del visor.

## Seguridad
- Validación de parámetros en backend.
- El endpoint puede protegerse con middleware de autenticación según necesidades del proyecto.

## Consideraciones
- El visor cartográfico es externo y se embebe vía iframe.
- El parámetro `clavePredi0` es sensible a errores de tipeo; se recomienda validación adicional si es necesario.
- El componente Vue.js es una página independiente, no utiliza tabs ni layouts compartidos.

## Extensibilidad
- El endpoint `/api/execute` puede ampliarse para soportar más acciones.
- El stored procedure puede evolucionar para validar la existencia de la clave catastral en la base de datos si se requiere.
