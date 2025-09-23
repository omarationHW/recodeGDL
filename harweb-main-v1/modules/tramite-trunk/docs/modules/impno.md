# Documentación Técnica: Migración de Formulario impno (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de impresión de notificaciones de predios (impno) desde Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend) y PostgreSQL (base de datos). Toda la lógica de consulta y armado de datos se centraliza en un stored procedure, y la impresión se simula en el backend.

## 2. Arquitectura
- **Frontend:** Vue.js SPA, cada formulario es una página independiente.
- **Backend:** Laravel, con un endpoint unificado `/api/execute` que recibe un `eRequest` y parámetros.
- **Base de Datos:** PostgreSQL, lógica de consulta compleja en stored procedures.

## 3. Flujo de Datos
1. El usuario ingresa los datos requeridos (recaud, tipo de predio, cuenta) y presiona "Buscar".
2. El frontend envía un POST a `/api/execute` con `eRequest: 'impno_get_notification_data'` y los parámetros.
3. Laravel recibe la petición, llama al stored procedure `sp_impno_get_notification_data` y retorna los datos en formato JSON.
4. El usuario puede presionar "Imprimir Notificación", lo que envía otro POST a `/api/execute` con `eRequest: 'impno_print_notification'`.

## 4. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Body:**
  ```json
  {
    "eRequest": "impno_get_notification_data",
    "params": {
      "recaud": "...",
      "urbrus": "U|R",
      "cuenta": "..."
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": { ... },
      "message": "..."
    }
  }
  ```

## 5. Stored Procedure
Toda la lógica de consulta y armado de datos para la notificación se encuentra en `sp_impno_get_notification_data`, que retorna un JSON con todos los datos relacionados.

## 6. Validaciones
- Todos los campos son obligatorios.
- El tipo de predio debe ser 'U' o 'R'.
- Si no se encuentra el registro, se retorna un mensaje de error.

## 7. Impresión
- La impresión real debe implementarse según los requerimientos (PDF, impresora física, etc.). Actualmente, se simula la impresión en el backend.

## 8. Seguridad
- Se recomienda proteger el endpoint `/api/execute` con autenticación y autorización según el contexto de la aplicación.

## 9. Extensibilidad
- El endpoint unificado permite agregar nuevos procesos y formularios reutilizando el mismo patrón eRequest/eResponse.

## 10. Pruebas
- Se proveen casos de uso y escenarios de prueba para validar la funcionalidad.
