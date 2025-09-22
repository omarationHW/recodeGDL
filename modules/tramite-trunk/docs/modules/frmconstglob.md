# Documentación Técnica: Migración de Formulario frmconstglob (Construcciones Globales)

## 1. Descripción General
Este módulo corresponde a la migración del formulario Delphi `frmconstglob` a una arquitectura moderna basada en Laravel (backend/API), Vue.js (frontend SPA), y PostgreSQL (base de datos y lógica de negocio). El formulario permite la consulta, alta, edición y eliminación de construcciones globales asociadas a una clave catastral.

## 2. Arquitectura
- **Backend:** Laravel Controller único (`CondominioGlobalController`) con endpoint `/api/execute` que recibe todas las operaciones vía un patrón eRequest/eResponse.
- **Frontend:** Componente Vue.js independiente, página completa, sin tabs, con navegación breadcrumb y formulario CRUD.
- **Base de Datos:** PostgreSQL, con stored procedures para todas las operaciones (listado, consulta, alta, edición, baja).

## 3. API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Entrada:**
  ```json
  {
    "eRequest": {
      "operation": "list|show|create|update|delete|report",
      "params": { ... }
    }
  }
  ```
- **Salida:**
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```

## 4. Stored Procedures
- Todos los procedimientos almacenados están en PostgreSQL y siguen la convención `sp_construc_*`.
- Cada operación (list, show, create, update, delete) tiene su propio SP.
- Los SPs devuelven datos en formato tabla o booleano según corresponda.

## 5. Frontend (Vue.js)
- Página independiente, sin tabs.
- Permite buscar por clave catastral, listar, agregar, editar y eliminar construcciones globales.
- Formulario reactivo, validación básica en frontend.
- Navegación breadcrumb.
- Acciones CRUD conectadas al endpoint `/api/execute`.

## 6. Backend (Laravel)
- Controlador único con método `execute` que enruta la operación solicitada.
- Cada operación llama a la función correspondiente (list, show, create, update, delete, report).
- Validación de parámetros y manejo de errores.
- Uso de DB Facade para ejecutar SQL y SPs.

## 7. Seguridad
- Todas las operaciones requieren autenticación (middleware Laravel, no mostrado aquí).
- Validación de parámetros en backend y frontend.

## 8. Consideraciones
- El endpoint es genérico y puede ser extendido para otros formularios.
- El frontend puede ser adaptado fácilmente a otras entidades.
- Los SPs pueden ser versionados y auditados en la base de datos.

## 9. Flujo de Datos
1. Usuario ingresa clave catastral y consulta construcciones globales.
2. Puede agregar, editar o eliminar registros.
3. Cada acción envía un eRequest al endpoint `/api/execute`.
4. El backend ejecuta el SP correspondiente y retorna eResponse.
5. El frontend actualiza la vista según la respuesta.

## 10. Ejemplo de eRequest/eResponse
### Solicitud de listado:
```json
{
  "eRequest": {
    "operation": "list",
    "params": { "cvecatnva": "D6512345678" }
  }
}
```
### Respuesta:
```json
{
  "eResponse": {
    "success": true,
    "message": "Listado obtenido",
    "data": [ ... ]
  }
}
```

## 11. Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas operaciones sin modificar el endpoint.
- Los SPs pueden ser reutilizados por otros módulos.

## 12. Pruebas y Validación
- Se recomienda usar Postman para pruebas de API.
- El frontend puede ser probado con Cypress o Jest.
- Los SPs pueden ser probados directamente en PostgreSQL.
