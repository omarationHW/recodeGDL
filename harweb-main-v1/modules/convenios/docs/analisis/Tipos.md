# Documentación Técnica: Migración de Formulario Tipos (Delphi) a Laravel + Vue.js + PostgreSQL

## Arquitectura General
- **Backend**: Laravel API, endpoint único `/api/execute` (POST), patrón eRequest/eResponse.
- **Frontend**: Vue.js SPA, página independiente para Tipos de Convenio.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.

## API Unificada
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Request**:
  ```json
  {
    "action": "get_tipos|add_tipo|update_tipo|delete_tipo",
    "payload": { ... }
  }
  ```
- **Response**:
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## Acciones Soportadas
- `get_tipos`: Lista todos los tipos de convenio.
- `add_tipo`: Agrega un nuevo tipo. Payload: `{ tipo, descripcion }`
- `update_tipo`: Modifica un tipo existente. Payload: `{ tipo, descripcion }`
- `delete_tipo`: Elimina un tipo. Payload: `{ tipo }`

## Seguridad
- Se recomienda proteger el endpoint con autenticación JWT o similar.
- Validaciones de datos en backend y frontend.

## Stored Procedures
- Toda la lógica de inserción, actualización y borrado está en SPs PostgreSQL.
- El controlador Laravel solo invoca los SPs.

## Vue.js
- Página independiente, sin tabs.
- CRUD completo, validación, feedback visual.
- Modal para alta/edición.
- Navegación breadcrumb.

## Consideraciones
- El campo `tipo` es clave primaria (integer).
- El campo `descripcion` es varchar(50).
- No se permite duplicados en `tipo`.
- Eliminar un tipo que tenga dependencias puede arrojar error (manejar en frontend/backend).

## Extensibilidad
- El patrón eRequest/eResponse permite agregar más acciones y módulos fácilmente.

## Ejemplo de Request/Response
- **Alta**:
  ```json
  { "action": "add_tipo", "payload": { "tipo": 5, "descripcion": "NUEVO TIPO" } }
  ```
- **Respuesta**:
  ```json
  { "success": true, "message": "Tipo agregado correctamente" }
  ```

# Diagrama de Flujo
1. Usuario accede a página Tipos (Vue.js)
2. Vue solicita `get_tipos` a `/api/execute`
3. Usuario agrega/modifica/elimina tipo
4. Vue envía acción a `/api/execute`
5. Laravel ejecuta SP correspondiente
6. Respuesta eResponse a Vue
7. Vue actualiza UI
