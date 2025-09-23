# Documentación Técnica: Migración Formulario SubTipoMntto Delphi a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel Controller con endpoint único `/api/execute` que recibe un objeto `eRequest` con acción y datos, y responde con `eResponse`.
- **Frontend**: Componente Vue.js independiente (página completa) para el catálogo de SubTipos.
- **Base de Datos**: PostgreSQL, lógica de negocio encapsulada en stored procedures.
- **Comunicación**: API unificada, patrón eRequest/eResponse.

## 2. API Backend
- **Ruta**: POST `/api/execute`
- **Request**:
  ```json
  {
    "eRequest": {
      "action": "list|get|create|update|catalog_tipos|catalog_cuentas",
      "data": { ... }
    }
  }
  ```
- **Response**:
  ```json
  {
    "eResponse": {
      "success": true|false,
      "message": "...",
      "data": [ ... ]
    }
  }
  ```
- **Acciones soportadas**:
  - `list`: Lista todos los SubTipos
  - `get`: Obtiene un SubTipo por tipo y subtipo
  - `create`: Crea un SubTipo (usa SP)
  - `update`: Actualiza un SubTipo (usa SP)
  - `catalog_tipos`: Catálogo de Tipos
  - `catalog_cuentas`: Catálogo de Cuentas de Aplicación

## 3. Stored Procedures
- Toda la lógica de inserción y actualización está en SPs:
  - `sp_subtipo_conv_create(tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario)`
  - `sp_subtipo_conv_update(tipo, subtipo, desc_subtipo, cuenta_ingreso, id_usuario)`
- Devuelven un registro con `success` y `message`.

## 4. Frontend Vue.js
- Página independiente, sin tabs.
- Formulario para alta/modificación de SubTipos.
- Tabla de listado editable.
- Catálogos de Tipos y Cuentas cargados por API.
- Validación básica en frontend y backend.
- Mensajes de éxito/error.

## 5. Seguridad
- El campo `id_usuario` debe venir del login (simulado en ejemplo).
- Validación de datos en backend y frontend.

## 6. Flujo de trabajo
1. El usuario accede a la página de SubTipos.
2. El frontend carga catálogos y listado vía API.
3. El usuario puede agregar o editar un SubTipo.
4. El backend valida y ejecuta el SP correspondiente.
5. El frontend muestra el resultado y refresca el listado.

## 7. Consideraciones
- El endpoint es único y multipropósito.
- Los SPs pueden ser extendidos para lógica adicional (auditoría, logs, etc).
- El frontend es desacoplado y puede integrarse en cualquier SPA Vue.js.

