# Documentación Técnica: Gestión de Revisiones/Inspecciones de Trámite

## Descripción General
Este módulo permite la gestión de revisiones (inspecciones) asociadas a un trámite de licencias municipales. Permite agregar y eliminar inspecciones (dependencias) a un trámite, mostrando las inspecciones actuales y permitiendo la selección de nuevas dependencias desde un catálogo.

La arquitectura sigue el patrón eRequest/eResponse con un endpoint único `/api/execute` en Laravel, y un componente Vue.js de página completa. Toda la lógica de acceso a datos se implementa en stored procedures PostgreSQL.

## Arquitectura
- **Backend:** Laravel Controller (`DependenciasController`) con endpoint `/api/execute`.
- **Frontend:** Componente Vue.js independiente (`DependenciasPage.vue`), sin tabs, con navegación breadcrumb.
- **Base de datos:** PostgreSQL, lógica en stored procedures.
- **API:** Única vía `/api/execute` con parámetros `action` y `params`.

## Flujo de Datos
1. El frontend solicita el catálogo de dependencias (`get_dependencias`).
2. Solicita las inspecciones actuales del trámite (`get_tramite_inspecciones`).
3. Permite agregar una inspección (`add_inspeccion`) o eliminarla (`delete_inspeccion`).
4. Toda la lógica de negocio y validación reside en los stored procedures.

## Formato de Mensajes API
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
    "data": ...,
    "message": "..."
  }
  ```

## Seguridad
- El endpoint puede requerir autenticación (ejemplo: `$request->user()` en Laravel).
- El usuario que realiza la acción se registra en la tabla de seguimiento (`seg_revision`).

## Stored Procedures
- Todos los accesos y modificaciones a la base de datos se realizan mediante stored procedures:
  - `sp_get_dependencias`: Catálogo de dependencias.
  - `sp_get_tramite_inspecciones`: Inspecciones actuales de un trámite.
  - `sp_add_inspeccion`: Agrega una inspección a un trámite.
  - `sp_delete_inspeccion`: Elimina una inspección de un trámite.
  - `sp_get_tramite_info`: Información básica del trámite.

## Integración Vue.js
- El componente Vue.js es una página completa, sin tabs.
- Permite agregar y eliminar inspecciones en tiempo real.
- Usa fetch API para comunicarse con `/api/execute`.

## Consideraciones de Integración
- El endpoint `/api/execute` debe estar registrado en `routes/api.php`.
- El controlador debe estar registrado y protegido según la política de autenticación.
- Los stored procedures deben estar creados en la base de datos PostgreSQL.

## Validaciones
- No se puede agregar una inspección ya existente.
- No se puede eliminar una inspección inexistente.
- El id_tramite debe existir y ser válido.

## Ejemplo de Request/Response
### Obtener dependencias
```json
{
  "action": "get_dependencias",
  "params": {}
}
```

### Agregar inspección
```json
{
  "action": "add_inspeccion",
  "params": {
    "id_tramite": 123,
    "id_dependencia": 22
  }
}
```

### Eliminar inspección
```json
{
  "action": "delete_inspeccion",
  "params": {
    "id_tramite": 123,
    "id_dependencia": 22
  }
}
```

## Manejo de Errores
- El backend responde con `success: false` y un mensaje descriptivo en caso de error o validación fallida.

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones sin modificar el endpoint.
- Los stored procedures pueden ampliarse para nuevas reglas de negocio.
