# Documentación Técnica - Migración Formulario CategoriaMntto (Delphi → Laravel + Vue.js + PostgreSQL)

## 1. Arquitectura General
- **Backend:** Laravel 10+, PostgreSQL 13+
- **Frontend:** Vue.js 2/3 SPA (Single Page Application)
- **API:** Unificada, endpoint único `/api/execute` (patrón eRequest/eResponse)
- **Base de datos:** PostgreSQL, lógica de negocio en stored procedures

## 2. API Unificada (eRequest/eResponse)
- **Endpoint:** `POST /api/execute`
- **Request:**
  ```json
  {
    "action": "categoria.create|categoria.update|categoria.delete|categoria.list",
    "data": { ... }
  }
  ```
- **Response:**
  ```json
  {
    "success": true|false,
    "message": "Mensaje de error o éxito",
    "data": [ ... ]
  }
  ```

## 3. Controlador Laravel
- Un solo método `execute(Request $request)`
- Ruteo por campo `action` (ej: `categoria.create`, `categoria.update`, etc)
- Validación de datos con `Validator`
- Llama a los stored procedures PostgreSQL vía `DB::select()`
- Devuelve respuesta JSON estándar

## 4. Stored Procedures PostgreSQL
- Toda la lógica de inserción, actualización, borrado y consulta está en SPs
- Cada SP retorna un registro con `success` y `message` para operaciones de escritura
- El SP de listado retorna un TABLE

## 5. Componente Vue.js
- Página independiente, sin tabs
- Formulario para alta/modificación de categoría
- Tabla de listado con acciones editar/eliminar
- Mensajes de error y éxito
- Navegación breadcrumb
- Lógica de edición y borrado inline
- Axios para llamadas a `/api/execute`

## 6. Seguridad
- Validación de datos en backend y frontend
- No se permite duplicidad de clave
- Descripción en mayúsculas (frontend y backend)

## 7. Consideraciones de Integración
- El endpoint `/api/execute` puede ser extendido para otros catálogos y procesos
- El frontend puede ser adaptado para otros catálogos con mínima modificación
- Los SPs pueden ser versionados y auditados en el esquema de la base de datos

## 8. Migración de Datos
- Para migrar datos existentes, usar scripts de ETL o migración directa a la tabla `ta_11_categoria`

## 9. Pruebas y Auditoría
- Todos los cambios quedan registrados en la base de datos
- Se recomienda auditar los cambios críticos en tablas de log si es necesario

## 10. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint
- Los SPs pueden ser reutilizados por otros sistemas
