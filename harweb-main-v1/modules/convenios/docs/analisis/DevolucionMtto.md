# Documentación Técnica: Migración Formulario DevoluciónMtto (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel API (PHP 8+), PostgreSQL, endpoint único `/api/execute` (patrón eRequest/eResponse).
- **Frontend:** Vue.js SPA, componente de página independiente para DevoluciónMtto.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.

## 2. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "payload": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": ...,
    "message": "..."
  }
  ```
- **Acciones soportadas:**
  - `list_devoluciones` (listar devoluciones por contrato)
  - `get_contrato` (buscar contrato por colonia/calle/folio)
  - `get_pagos` (total pagado por contrato)
  - `create_devolucion` (alta)
  - `update_devolucion` (modificación)
  - `delete_devolucion` (baja)

## 3. Stored Procedures
- Toda la lógica de inserción, actualización y borrado de devoluciones se realiza vía SPs PostgreSQL:
  - `sp_create_devolucion_mtto`
  - `sp_update_devolucion_mtto`
  - `sp_delete_devolucion_mtto`

## 4. Validaciones
- Validación de campos obligatorios y tipos en backend (Laravel) y frontend (Vue).
- El frontend previene errores de usuario (campos requeridos, solo números, etc).
- El backend valida nuevamente antes de ejecutar SPs.

## 5. Seguridad
- El endpoint requiere autenticación (no incluida aquí, pero debe usarse middleware auth en producción).
- El id_usuario debe obtenerse del contexto de sesión/token.

## 6. Flujo de la Página Vue
1. Usuario ingresa colonia, calle, folio y pulsa Buscar.
2. Si existe el contrato, se muestran datos generales y devoluciones existentes.
3. Puede agregar, modificar o eliminar devoluciones.
4. Al guardar, se llama a la API con la acción correspondiente.
5. Mensajes de éxito/error se muestran en pantalla.

## 7. Consideraciones de Migración
- El formulario Delphi usaba componentes visuales y lógica procedural; ahora todo es desacoplado y RESTful.
- El frontend es una página independiente, sin tabs ni subformularios.
- El backend es desacoplado y puede ser consumido por cualquier cliente.

## 8. Extensibilidad
- El endpoint `/api/execute` puede ser extendido para otras acciones y formularios.
- Los SPs pueden ser versionados y auditados en la base de datos.

## 9. Pruebas
- Se recomienda usar Postman para pruebas de API y Cypress/Jest para frontend.

## 10. Mantenimiento
- Los cambios en la lógica de negocio deben realizarse en los SPs y reflejarse en el controlador Laravel.
- El frontend puede ser extendido fácilmente para nuevos campos o validaciones.
