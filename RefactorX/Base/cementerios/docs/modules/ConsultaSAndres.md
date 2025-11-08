# Documentación Técnica: Migración Formulario ConsultaSAndres (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo corresponde a la migración del formulario de consulta de la base de datos del Cementerio San Andrés, originalmente implementado en Delphi, a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3+, componente de página independiente.
- **Base de Datos:** PostgreSQL, lógica encapsulada en stored procedures.

## 3. API Unificada (eRequest/eResponse)
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Payload:**
  ```json
  {
    "action": "consultar_sanandres", // o 'consultar_sanandres_paginated'
    "params": { "page": 1, "per_page": 20 }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "data": [...],
    "message": ""
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta reside en stored procedures PostgreSQL (`sp_consultar_sanandres`, `sp_consultar_sanandres_paginated`, `sp_total_sanandres`).
- El controlador Laravel invoca estos procedimientos vía DB::select.

## 5. Frontend (Vue.js)
- El componente es una página completa, no usa tabs ni subcomponentes.
- Implementa tabla responsive, paginación, carga inicial y navegación.
- El botón "Salir" regresa a la página anterior usando el router.

## 6. Seguridad
- El endpoint `/api/execute` debe protegerse con autenticación (ej: JWT) en producción.
- Validar los parámetros recibidos para evitar SQL Injection (Laravel lo hace por defecto con bindings).

## 7. Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones fácilmente.
- El frontend puede consumir otros formularios siguiendo el mismo patrón.

## 8. Consideraciones de Migración
- Los nombres de columnas y tablas deben coincidir con la estructura original.
- Si la tabla `datos` tiene más campos, deben agregarse en los stored procedures y frontend.
- El formulario Delphi original no tenía filtros; la versión Vue.js implementa paginación para grandes volúmenes.

## 9. Pruebas
- Se recomienda usar Postman para probar el endpoint `/api/execute`.
- El frontend puede probarse con datos reales o mockeados.

## 10. Mantenimiento
- Para agregar nuevos formularios, crear nuevos stored procedures y acciones en el controlador.
- El frontend puede duplicar el componente y cambiar la acción/estructura según el formulario.
