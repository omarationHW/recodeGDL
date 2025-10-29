# Documentación Técnica: Migración de Formulario Delphi a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `prophologramasfrm` (Propietarios de Hologramas) a una arquitectura moderna basada en Laravel (API), Vue.js (Frontend) y PostgreSQL (Base de datos). La funcionalidad principal es el mantenimiento (CRUD) de la tabla `c_contribholog`.

## 2. Arquitectura
- **Backend:** Laravel expone un único endpoint `/api/execute` que recibe un objeto `eRequest` con la operación y parámetros. Todas las operaciones CRUD se delegan a stored procedures en PostgreSQL.
- **Frontend:** Un componente Vue.js independiente, que implementa la vista y edición de los propietarios de hologramas, con navegación tipo página y sin tabs.
- **Base de Datos:** Toda la lógica de acceso y manipulación de datos se realiza mediante stored procedures.

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Request:**
  ```json
  {
    "eRequest": {
      "operation": "nombre_operacion",
      "params": { ... }
    }
  }
  ```
- **Response:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "data": [ ... ] | { ... } | null,
      "message": "Mensaje de error o éxito"
    }
  }
  ```
- **Operaciones soportadas:**
  - `get_contribholog_list`
  - `get_contribholog_by_id`
  - `insert_contribholog`
  - `update_contribholog`
  - `delete_contribholog`

## 4. Stored Procedures
- Toda la lógica de acceso a datos está encapsulada en funciones de PostgreSQL.
- Cada función retorna el registro afectado o la lista solicitada.

## 5. Validaciones
- El backend valida los parámetros requeridos antes de invocar los stored procedures.
- El frontend valida campos obligatorios y formato de email.

## 6. Seguridad
- El endpoint debe protegerse con autenticación (no incluida en este ejemplo).
- Se recomienda usar CSRF y autenticación JWT o session para producción.

## 7. Frontend
- El componente Vue.js es una página completa, con tabla de registros y formulario de edición/agregado.
- No se usan tabs ni componentes compartidos con otros formularios.
- Incluye navegación breadcrumb.
- El formulario convierte automáticamente los campos de texto a mayúsculas donde corresponde.

## 8. Consideraciones de Migración
- El campo `feccap` se asigna automáticamente en el insert (NOW()).
- El campo `capturista` debe ser proporcionado por el usuario (o por el sistema si hay login).
- El campo `idcontrib` es autoincremental (serial/integer).

## 9. Pruebas
- Se recomienda probar todos los escenarios de inserción, edición, borrado y validación de errores.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones fácilmente.
- Los stored procedures pueden ser extendidos para lógica adicional (auditoría, validaciones, etc).
