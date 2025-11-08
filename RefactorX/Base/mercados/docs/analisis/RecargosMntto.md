# Documentación Técnica: Migración Formulario RecargosMntto (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de los recargos de mantenimiento por año y periodo. Incluye la inserción, modificación y consulta de recargos, así como la visualización de todos los registros existentes. La migración implementa una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos), centralizando la lógica de negocio en stored procedures y exponiendo la funcionalidad a través de un endpoint API unificado.

## 2. Arquitectura
- **Backend:** Laravel 10+, controlador único (`RecargosMnttoController`) que expone el endpoint `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs, con navegación breadcrumb y tabla de recargos editable.
- **Base de Datos:** PostgreSQL, toda la lógica de negocio encapsulada en stored procedures (`sp_insert_recargo`, `sp_update_recargo`, `sp_get_recargo`, `sp_list_recargos`).

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "nombre_accion", // Ej: "insert_recargo", "update_recargo", "get_recargo", "list_recargos"
    "params": { ... } // Parámetros requeridos por la acción
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [ ... ], // o null
    "message": "Mensaje de éxito o error"
  }
  ```

## 4. Stored Procedures
- Toda la lógica de inserción, actualización y consulta reside en funciones PL/pgSQL.
- Se validan duplicados y existencia antes de insertar/actualizar.
- Se retorna siempre un mensaje y un flag de éxito.

## 5. Frontend (Vue.js)
- Página independiente `/recargos-mntto`.
- Formulario para alta/modificación de recargos.
- Tabla con todos los recargos existentes.
- Edición inline (al hacer click en editar, el formulario se llena y permite actualizar).
- Mensajes de éxito/error en pantalla.
- Navegación breadcrumb.

## 6. Seguridad
- El endpoint espera que el usuario autenticado esté disponible (en este ejemplo, se usa `id_usuario: 1` por defecto, pero debe integrarse con el sistema de autenticación real).
- Validaciones de datos tanto en frontend como en backend.

## 7. Consideraciones de Migración
- El formulario Delphi usaba transacciones y control de errores; esto se replica en los stored procedures y el controlador Laravel.
- El frontend es completamente reactivo y no usa tabs ni componentes compartidos con otros formularios.
- El endpoint `/api/execute` puede ser extendido para otros formularios siguiendo el mismo patrón.

## 8. Instalación y Despliegue
- Crear las funciones PL/pgSQL en la base de datos PostgreSQL.
- Registrar el controlador en `routes/api.php`:
  ```php
  Route::post('/execute', [RecargosMnttoController::class, 'execute']);
  ```
- Agregar el componente Vue.js en la SPA y registrar la ruta `/recargos-mntto`.

## 9. Ejemplo de Request/Response
- **Alta de recargo:**
  ```json
  {
    "action": "insert_recargo",
    "params": {
      "axo": 2024,
      "periodo": 6,
      "porcentaje": 2.5,
      "id_usuario": 1
    }
  }
  ```
- **Respuesta:**
  ```json
  {
    "success": true,
    "message": "Recargo insertado correctamente."
  }
  ```

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones y stored procedures sin modificar la estructura del endpoint.
- El frontend puede ser extendido para otros catálogos siguiendo el mismo patrón de página independiente.
