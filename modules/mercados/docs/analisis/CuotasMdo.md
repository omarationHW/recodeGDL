# Documentación Técnica: Migración Formulario CuotasMdo (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend:** Laravel 10+ (PHP 8+), API RESTful, endpoint único `/api/execute`.
- **Frontend:** Vue.js 3 SPA, cada formulario es una página independiente.
- **Base de Datos:** PostgreSQL, lógica de negocio en stored procedures.
- **Patrón API:** eRequest/eResponse (acción + parámetros).

## 2. Endpoint API Unificado
- **Ruta:** `/api/execute` (POST)
- **Request:**
  ```json
  {
    "action": "nombre_accion",
    "params": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "data": [...],
    "message": "..."
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute` que despacha según `action`.
- Validación de parámetros con `Validator`.
- Llama a stored procedures vía DB::select/DB::statement.
- Maneja errores y devuelve mensajes claros.

## 4. Stored Procedures PostgreSQL
- Toda la lógica de CRUD y catálogos está en stored procedures.
- Ejemplo: `sp_cuotasmdo_list`, `sp_cuotasmdo_create`, etc.
- Cada SP retorna datos en formato tabla o VOID según corresponda.

## 5. Componente Vue.js
- Página independiente para CuotasMdo.
- Tabla con listado, botones para agregar/editar/eliminar.
- Modal para crear/editar.
- Usa axios para consumir `/api/execute`.
- Filtros para moneda y fecha.
- Breadcrumb para navegación.

## 6. Seguridad
- Validación de usuario (`id_usuario`) en cada operación.
- Los stored procedures pueden ser extendidos para validar permisos si es necesario.

## 7. Extensibilidad
- El endpoint `/api/execute` puede despachar cualquier acción del sistema.
- Los catálogos (categorías, secciones, claves de cuota) se obtienen vía SPs.

## 8. Manejo de Errores
- El backend devuelve `success: false` y un mensaje en caso de error.
- El frontend muestra alertas en caso de error.

## 9. Pruebas y Casos de Uso
- Se proveen casos de uso y escenarios de prueba para QA y UAT.

## 10. Notas de Migración
- Los nombres de tablas y campos se mantienen fieles al modelo Delphi.
- Los triggers y lógica de negocio compleja deben migrarse a SPs.
- El frontend NO usa tabs, cada formulario es una página.

---
