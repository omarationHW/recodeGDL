# Documentación Técnica: Cancelación de Trámites

## Descripción General
Este módulo permite la consulta y cancelación de trámites desde una interfaz web desarrollada en Vue.js, comunicándose con un backend Laravel que expone un endpoint unificado `/api/execute` bajo el patrón eRequest/eResponse. Toda la lógica de negocio y acceso a datos se implementa mediante stored procedures en PostgreSQL.

## Arquitectura
- **Frontend:** Vue.js (SPA, página independiente por formulario)
- **Backend:** Laravel (API REST, endpoint único `/api/execute`)
- **Base de Datos:** PostgreSQL (Stored Procedures)

## Flujo de Trabajo
1. El usuario ingresa el número de trámite y consulta sus datos.
2. Si el trámite está en estado cancelable, puede proceder a cancelarlo ingresando un motivo.
3. El backend valida el estado y actualiza el trámite usando un stored procedure.

## Endpoint API
- **POST /api/execute**
  - **Body:**
    - `action`: (string) Acción a ejecutar (`get_tramite_by_id`, `cancel_tramite`, `get_giro_by_id`)
    - `params`: (object) Parámetros requeridos por la acción
  - **Response:**
    - `success`: (bool)
    - `data`: (array/object) Resultado de la acción
    - `message`: (string) Mensaje de error o éxito

## Stored Procedures
- `sp_get_tramite_by_id`: Devuelve todos los datos del trámite por su ID.
- `sp_get_giro_by_id`: Devuelve la descripción del giro por su ID.
- `sp_cancel_tramite`: Cancela el trámite si es posible y almacena el motivo.

## Validaciones
- No se puede cancelar un trámite ya cancelado (`estatus = 'C'`).
- No se puede cancelar un trámite aprobado (`estatus = 'A'`).
- El motivo de cancelación es obligatorio.

## Seguridad
- Todas las operaciones se realizan mediante stored procedures para evitar SQL Injection.
- El endpoint valida los parámetros requeridos.

## Manejo de Errores
- Mensajes claros para el usuario en caso de error (trámite no encontrado, ya cancelado, etc).
- Respuestas HTTP adecuadas (400 para errores de parámetros, 500 para errores internos).

## Extensibilidad
- El endpoint `/api/execute` puede ser extendido para nuevas acciones agregando nuevos casos en el controlador y nuevos stored procedures.

## Notas de Migración
- El campo calculado `propietarionvo` se genera en frontend (Vue) concatenando los apellidos y nombre.
- La lógica de rechazo de revisiones no se implementa ya que en el Delphi estaba comentada.

# Estructura de Tablas Relevantes
- **tramites**: Contiene todos los datos del trámite, incluyendo estatus y motivo de cancelación (`espubic`).
- **c_giros**: Catálogo de giros comerciales.

# Ejemplo de Peticiones
- **Consultar trámite:**
  ```json
  {
    "action": "get_tramite_by_id",
    "params": { "id_tramite": 123 }
  }
  ```
- **Cancelar trámite:**
  ```json
  {
    "action": "cancel_tramite",
    "params": { "id_tramite": 123, "motivo": "No procede" }
  }
  ```

# Consideraciones
- El frontend asume que el backend retorna los campos con los mismos nombres que en la base de datos.
- El motivo de cancelación se concatena con el texto fijo como en el sistema original.
