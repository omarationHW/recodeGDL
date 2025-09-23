# Documentación Técnica: Migración de Formulario RActualiza (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Frontend**: Vue.js SPA (Single Page Application), cada formulario es una página independiente.
- **Backend**: Laravel API RESTful, endpoint único `/api/execute` que recibe eRequest/eResponse.
- **Base de Datos**: PostgreSQL, toda la lógica de negocio relevante se implementa en stored procedures (SP).

## 2. API Unificada (eRequest/eResponse)
- **Endpoint**: `POST /api/execute`
- **Request Body**:
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true|false,
    "data": [...],
    "error": "mensaje de error"
  }
  ```
- **Acciones soportadas**:
  - `buscar_concesion`: Busca un local/concesión por control.
  - `actualizar_concesion`: Actualiza datos de concesión/local según opción.
  - `verificar_pagos`: Verifica si existen pagos a partir de un periodo.

## 3. Stored Procedures (PostgreSQL)
- Toda la lógica de negocio relevante (validaciones, actualizaciones, reglas de negocio) se implementa en SP.
- Los SP devuelven siempre un resultado estructurado (código de resultado y mensaje).
- Los SP están documentados y versionados.

## 4. Frontend (Vue.js)
- Cada formulario es una página independiente (NO tabs).
- Navegación mediante rutas y breadcrumbs.
- Validaciones en frontend y backend.
- Llamadas a `/api/execute` usando Axios.
- Manejo de mensajes de error y éxito.

## 5. Backend (Laravel)
- Controlador único (`ExecuteController`) que enruta la acción al SP correspondiente.
- Uso de transacciones si es necesario.
- Manejo de errores y logging.

## 6. Seguridad
- Autenticación recomendada vía Laravel Sanctum o Passport.
- Validación de parámetros en backend.

## 7. Pruebas
- Casos de uso y escenarios de prueba definidos.
- Se recomienda usar PHPUnit para backend y Cypress/Jest para frontend.

## 8. Convenciones
- Todas las fechas en formato `YYYY-MM` o ISO.
- Los SP deben ser idempotentes y seguros.
- Los mensajes de error deben ser claros para el usuario final.

## 9. Ejemplo de Flujo
1. Usuario ingresa número y letra de local y presiona Buscar.
2. Frontend llama a `/api/execute` con `action: 'buscar_concesion'`.
3. Backend ejecuta SP y devuelve datos del local.
4. Usuario selecciona tipo de actualización y llena los campos requeridos.
5. Frontend llama a `/api/execute` con `action: 'actualizar_concesion'` y los parámetros.
6. Backend ejecuta SP, valida reglas y devuelve resultado.
7. Frontend muestra mensaje de éxito o error.

## 10. Extensibilidad
- Para agregar nuevas acciones, basta con crear el SP y agregar el case correspondiente en el controlador.
- El frontend puede extenderse fácilmente para nuevos formularios.
