# Documentación Técnica: Migración de Formulario consmulpresc (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la consulta, alta, edición y eliminación de prescripciones de multas (presc_multas) en el sistema BasePHP, migrando la funcionalidad del formulario consmulpresc de Delphi a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA) y PostgreSQL (base de datos).

## 2. Arquitectura
- **Backend:** Laravel Controller con endpoint único `/api/execute` que recibe eRequest con acción y parámetros, y responde con eResponse.
- **Frontend:** Componente Vue.js independiente (sin tabs), que muestra la lista y formulario de prescripciones.
- **Base de Datos:** PostgreSQL, toda la lógica SQL encapsulada en stored procedures (SPs).

## 3. API Unificada
- **Endpoint:** `/api/execute` (POST)
- **Entrada:**
  ```json
  {
    "action": "list_prescriptions|get_prescription|create_prescription|update_prescription|delete_prescription",
    "params": { ... },
    "user": "usuario_actual"
  }
  ```
- **Salida:**
  ```json
  {
    "status": "success|error|not_found",
    "data": [ ... ] | { ... },
    "message": "Mensaje de error o éxito",
    "errors": [ ... ]
  }
  ```

## 4. Stored Procedures
- Toda la lógica de consulta, alta, edición y borrado de prescripciones está en SPs PostgreSQL:
  - `sp_list_presc_multas()`
  - `sp_get_presc_multa(id)`
  - `sp_create_presc_multa(...)`
  - `sp_update_presc_multa(...)`
  - `sp_delete_presc_multa(id)`

## 5. Seguridad
- El endpoint debe validar autenticación y autorización (middleware Laravel).
- Validación de datos en backend (Laravel Validator) y frontend (Vue.js, campos requeridos).

## 6. Frontend (Vue.js)
- Página independiente, sin tabs.
- Tabla de prescripciones con acciones de editar/eliminar.
- Formulario modal para alta/edición.
- Navegación breadcrumb.
- Mensajes de error y éxito.
- Responsive.

## 7. Backend (Laravel)
- Controlador centralizado, patrón switch para acciones.
- Uso de DB::select para invocar SPs.
- Validación de parámetros.
- Manejo de errores y mensajes.

## 8. Base de Datos
- Tabla principal: `presc_multas` (id_prescri, fecaut, fecha_prescri, oficio, capturista, dependencia, observaciones, id_multa)
- Índices en id_prescri, id_multa.

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas.

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin cambiar la estructura del endpoint.
- El frontend puede ser extendido fácilmente para filtros, paginación, etc.

---
