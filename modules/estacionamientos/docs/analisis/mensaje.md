# Documentación Técnica: Migración Formulario 'mensaje' Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo implementa la funcionalidad de mostrar mensajes del sistema, migrando el formulario Delphi a una arquitectura web moderna usando Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). El mensaje puede ser de tipo informativo, advertencia, error, etc., y muestra un ícono correspondiente.

## 2. Arquitectura
- **Frontend:** Componente Vue.js independiente, página completa, recibe parámetros por querystring (`tipo`, `msg`, `icono`).
- **Backend:** Laravel Controller con endpoint unificado `/api/execute` que recibe un objeto `eRequest` y responde con `eResponse`.
- **Base de Datos:** Stored Procedure en PostgreSQL para registrar o procesar la visualización del mensaje.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "action": "show_message",
      "params": {
        "tipo": "Error",
        "msg": "Ocurrió un error inesperado.",
        "icono": "alto"
      }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true,
      "data": {
        "tipo": "Error",
        "msg": "Ocurrió un error inesperado.",
        "icono": "alto"
      },
      "message": "Mensaje procesado correctamente."
    }
  }
  ```

## 4. Stored Procedure
- **Nombre:** `sp_mensaje_show`
- **Propósito:** Procesar y/o registrar la visualización de un mensaje. Puede ser extendido para logging.
- **Parámetros:**
  - `tipo` (TEXT): Tipo de mensaje (Error, Información, etc.)
  - `msg` (TEXT): Texto del mensaje
  - `icono` (TEXT): Tipo de ícono a mostrar
- **Retorno:** El mismo mensaje recibido (puede ser extendido).

## 5. Frontend (Vue.js)
- Página completa, sin tabs.
- Recibe parámetros por querystring.
- Muestra el mensaje y el ícono correspondiente.
- Botón "Aceptar" para cerrar o volver atrás.
- Llama al endpoint `/api/execute` para registrar el mensaje.

## 6. Seguridad
- El endpoint puede ser protegido con autenticación si se requiere.
- Validar los parámetros recibidos para evitar inyecciones.

## 7. Extensibilidad
- El stored procedure puede registrar los mensajes en una tabla de auditoría.
- El controlador puede manejar más acciones en el futuro.

## 8. Recursos Estáticos
- Los íconos deben estar disponibles en `/public/icons/` con nombres: `pregunta.png`, `admiracion.png`, `alto.png`, `informacion.png`.

## 9. Pruebas
- Ver sección de Casos de Uso y Casos de Prueba.
