# Documentación Técnica: Migración de Formulario "Quien elaboró convenio" (ElaboroConvenio)

## Arquitectura General
- **Backend:** Laravel (PHP 8+) usando un único endpoint `/api/execute` para todas las operaciones (patrón eRequest/eResponse).
- **Frontend:** Vue.js (SPA, componente de página independiente, sin tabs).
- **Base de Datos:** PostgreSQL, toda la lógica de acceso y manipulación de datos se realiza mediante stored procedures.

## API Unificada
- **Endpoint:** `/api/execute`
- **Método:** POST
- **Formato de petición:**
  ```json
  {
    "action": "list|create|update|delete",
    "params": { ... }
  }
  ```
- **Formato de respuesta:**
  ```json
  {
    "success": true|false,
    "data": [ ... ],
    "message": "..."
  }
  ```

## Stored Procedures
- Todas las operaciones CRUD y de catálogo se realizan mediante funciones PostgreSQL (ver sección `stored_procedures`).
- Los procedimientos devuelven siempre un TABLE para facilitar el consumo desde Laravel.

## Controlador Laravel
- El controlador recibe la acción y los parámetros, valida, y ejecuta el stored procedure correspondiente.
- Todas las validaciones de negocio básicas se realizan en el controlador antes de llamar al SP.
- Los errores de validación y de ejecución se devuelven en el campo `message`.

## Componente Vue.js
- Página independiente, sin tabs ni subcomponentes.
- Permite listar, agregar, modificar y eliminar registros.
- Usa modales para formularios de alta/modificación.
- Navegación breadcrumb incluida.
- Manejo de errores y loading.

## Seguridad
- Se asume autenticación JWT o session en Laravel (no incluida aquí).
- Validación de datos en backend y frontend.

## Integración
- El frontend se comunica exclusivamente con `/api/execute`.
- El backend traduce la acción a la función SQL correspondiente.

## Migración de Datos
- La tabla `ta_17_elaboroficio` debe existir en PostgreSQL con los campos:
  - id_control (PK, serial)
  - id_rec (integer)
  - id_usu_titular (integer)
  - iniciales_titular (varchar(10))
  - id_usu_elaboro (integer)
  - iniciales_elaboro (varchar(10))

## Consideraciones
- El catálogo de usuarios (`ta_12_passwords`) debe estar sincronizado.
- Los nombres de usuario se obtienen por JOIN en los SP.
- El frontend asume que los IDs de usuario y recaudadora son conocidos (pueden integrarse selectores si se requiere).

## Extensibilidad
- El patrón eRequest/eResponse permite agregar nuevas acciones fácilmente.
- Los stored procedures pueden ampliarse para lógica adicional (auditoría, logs, etc).

