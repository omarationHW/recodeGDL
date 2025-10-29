# Documentación Técnica: Migración de Formulario webBrowser (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `webBrowser` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos). El formulario permite al usuario ingresar una URL y visualizarla en un iframe, simulando la funcionalidad de un navegador web embebido.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel API, endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse.
- **Base de Datos:** PostgreSQL, con procedimientos almacenados para procesos relevantes (ej: logging de navegación).

## 3. Flujo de Trabajo
1. El usuario accede a la página "Localiza predio".
2. Se muestra un campo para ingresar la URL y un iframe con la URL por defecto.
3. Al salir del campo (blur), se envía la URL al backend vía `/api/execute` con acción `navigate_url`.
4. El backend valida la URL y responde con la misma (o error).
5. El frontend actualiza el iframe con la URL recibida.
6. (Opcional) Se puede registrar el evento de navegación en la base de datos usando el SP `sp_log_navigation_event`.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "navigate_url",
      "data": {
        "url": "https://ejemplo.com"
      }
    }
  }
  ```
- **Response (éxito):**
  ```json
  {
    "eResponse": {
      "status": "success",
      "message": "Navigation successful",
      "data": {
        "url": "https://ejemplo.com"
      }
    }
  }
  ```
- **Response (error):**
  ```json
  {
    "eResponse": {
      "status": "error",
      "message": "URL is required",
      "data": null
    }
  }
  ```

## 5. Stored Procedures
- **sp_log_navigation_event:** Permite registrar eventos de navegación para auditoría.
- **Tabla sugerida:**
  ```sql
  CREATE TABLE navigation_events (
    id serial PRIMARY KEY,
    user_id integer,
    url text NOT NULL,
    ip_address varchar(45),
    event_time timestamp NOT NULL
  );
  ```

## 6. Seguridad
- Validación estricta de URLs en backend.
- (Opcional) Autenticación de usuario para registrar eventos.
- Sanitización de entradas en frontend y backend.

## 7. Consideraciones
- El iframe puede estar limitado por políticas CORS/X-Frame-Options de los sitios externos.
- El SP de logging es opcional y puede ser extendido según necesidades de auditoría.

## 8. Extensibilidad
- Se pueden agregar acciones adicionales al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El frontend puede ser extendido para más controles o validaciones.
