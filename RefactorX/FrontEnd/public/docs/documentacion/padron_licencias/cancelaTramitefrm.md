# Documentación Técnica: cancelaTramitefrm

## Análisis Técnico

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

## Casos de Prueba

# Casos de Prueba: Cancelación de Trámites

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| 1 | Consulta de trámite existente | id_tramite = 1001 | Se muestran todos los datos del trámite y giro |
| 2 | Consulta de trámite inexistente | id_tramite = 9999 | Mensaje: 'No se encontró el trámite.' |
| 3 | Cancelación exitosa | id_tramite = 1003, motivo = 'El solicitante lo pidió' | Mensaje: 'Trámite cancelado exitosamente.'; estatus = 'C' |
| 4 | Cancelar trámite ya cancelado | id_tramite = 1002, motivo = 'Prueba' | Mensaje: 'El trámite ya se encuentra cancelado.'; estatus = 'C' |
| 5 | Cancelar trámite aprobado | id_tramite = 1004 (estatus = 'A'), motivo = 'Prueba' | Mensaje: 'El trámite ya se encuentra aprobado. No se puede cancelar.'; estatus = 'A' |
| 6 | Cancelar trámite sin motivo | id_tramite = 1003, motivo = '' | Mensaje: 'Debe ingresar el motivo de la cancelación.' |

## Casos de Uso

# Casos de Uso - cancelaTramitefrm

**Categoría:** Form

## Caso de Uso 1: Consulta de trámite existente

**Descripción:** El usuario ingresa el número de trámite y visualiza todos los datos asociados.

**Precondiciones:**
El trámite con el ID proporcionado existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página de cancelación de trámites.
2. Ingresa el número de trámite en el campo correspondiente.
3. Presiona Enter o el botón Buscar.
4. El sistema muestra los datos del trámite y del giro asociado.

**Resultado esperado:**
Se muestran todos los datos del trámite, incluyendo propietario, ubicación, actividad, giro, etc.

**Datos de prueba:**
id_tramite: 1001 (existente en la tabla tramites)

---

## Caso de Uso 2: Intento de cancelar trámite ya cancelado

**Descripción:** El usuario intenta cancelar un trámite que ya tiene estatus 'C' (cancelado).

**Precondiciones:**
El trámite existe y su estatus es 'C'.

**Pasos a seguir:**
1. El usuario busca el trámite por su número.
2. El sistema muestra los datos y el botón 'Dar de baja' está deshabilitado.
3. El usuario no puede proceder a cancelar.

**Resultado esperado:**
El sistema informa que el trámite ya está cancelado y no permite la acción.

**Datos de prueba:**
id_tramite: 1002 (estatus = 'C')

---

## Caso de Uso 3: Cancelación exitosa de trámite

**Descripción:** El usuario cancela un trámite válido, ingresando el motivo correspondiente.

**Precondiciones:**
El trámite existe y su estatus no es 'C' ni 'A'.

**Pasos a seguir:**
1. El usuario busca el trámite por su número.
2. El sistema muestra los datos y el botón 'Dar de baja' está habilitado.
3. El usuario hace clic en 'Dar de baja'.
4. Ingresa el motivo en el modal y confirma.
5. El sistema ejecuta la cancelación y actualiza el estatus.

**Resultado esperado:**
El trámite cambia a estatus 'C' y el motivo se almacena correctamente.

**Datos de prueba:**
id_tramite: 1003 (estatus = 'P'), motivo: 'El solicitante lo pidió'

---

