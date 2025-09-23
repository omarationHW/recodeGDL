# Documentación Técnica: Migración de Formulario descmultalic (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Descripción General
Este módulo permite la gestión de descuentos a multas de licencias municipales. Incluye:
- Consulta de licencias y sus descuentos vigentes
- Alta, edición y cancelación de descuentos
- Validación de permisos y reglas de negocio
- Integración con requerimientos y folios

## 2. Arquitectura
- **Backend:** Laravel Controller (DescmultalicController) expone un endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y parámetros. Todas las operaciones CRUD y de proceso se delegan a stored procedures en PostgreSQL.
- **Frontend:** Componente Vue.js de página completa, sin tabs, con navegación breadcrumb y formularios independientes.
- **Base de Datos:** PostgreSQL, con stored procedures para todas las operaciones principales.

## 3. API Unificada
- **Endpoint:** `POST /api/execute`
- **Entrada:**
  ```json
  {
    "eRequest": {
      "module": "descmultalic",
      "action": "list|show|create|update|delete|cancel|folio|licencia|autoriza",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "result": ...,
      "error": ...
    }
  }
  ```

## 4. Stored Procedures
- `sp_descmultalic_create`: Alta de descuento
- `sp_descmultalic_update`: Modificación
- `sp_descmultalic_delete`: Eliminación
- `sp_descmultalic_cancel`: Cancelación lógica
- `sp_descmultalic_folio`: Consulta de folios vigentes

## 5. Validaciones y Seguridad
- Solo un descuento vigente por licencia
- Porcentaje máximo según autoriza
- No se puede agregar descuento si ya existe uno vigente
- Cancelación requiere confirmación
- Todas las acciones quedan auditadas por usuario y fecha

## 6. Frontend (Vue.js)
- Página única por formulario
- Breadcrumb de navegación
- Formulario de búsqueda de licencia
- Listado de descuentos vigentes
- Formulario de alta/edición
- Botón de cancelación
- Mensajes de error y éxito

## 7. Integración
- El frontend consume el endpoint `/api/execute` usando el patrón eRequest/eResponse
- Todas las acciones (list, create, update, cancel, etc.) se ejecutan vía API
- El backend usa stored procedures para lógica de negocio

## 8. Migración de Datos
- Los datos existentes en la tabla `descmultalic` deben migrarse a PostgreSQL respetando los campos y tipos
- Los usuarios y permisos deben mapearse a la tabla `c_autdescmul`

## 9. Pruebas y Casos de Uso
- Ver sección de casos de uso y pruebas

## 10. Seguridad y Auditoría
- Todas las operaciones registran usuario y fecha
- Solo usuarios autorizados pueden crear/cancelar descuentos

