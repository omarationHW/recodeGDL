# Documentación Técnica: estatusfrm

## Análisis Técnico

# Documentación Técnica: Migración de estatusfrm (Delphi) a Laravel + Vue.js + PostgreSQL

## 1. Arquitectura General
- **Backend**: Laravel Controller con endpoint unificado `/api/execute` que recibe eRequest/eResponse.
- **Frontend**: Componente Vue.js independiente (no tabs), página completa para cambiar estatus de revisión.
- **Base de Datos**: PostgreSQL, lógica de negocio en stored procedures.
- **API**: Todas las operaciones se realizan vía POST a `/api/execute` con un campo `action` y un objeto `data`.

## 2. Flujo de Datos
1. El usuario accede a la página de cambio de estatus de revisión.
2. El componente Vue obtiene los datos actuales de la revisión y el catálogo de estatus vía `/api/execute`.
3. El usuario selecciona el nuevo estatus y llena los campos requeridos según reglas de negocio.
4. Al enviar, el componente llama a `/api/execute` con `action: 'changeEstatusRevision'` y los datos del formulario.
5. El backend valida y ejecuta el stored procedure `sp_cambiar_estatus_revision`, que actualiza las tablas necesarias.
6. El resultado se muestra en la UI.

## 3. Validaciones y Reglas de Negocio
- No se puede cambiar el estatus si ya está en 'A', 'C' o 'N'.
- Si el nuevo estatus es 'P' (Pendiente) o 'O' (Condicionado), se requiere fecha de prórroga.
- Si es 'A' (Aprobado) y la dependencia es comite de giros restringidos, se requiere calificación, costo y fecha de consejo.
- Si es 'N' (No aprobado), el trámite se marca como rechazado.
- Si es 'C' (Cancelado), el trámite se marca como cancelado.
- Si es 'A' y todas las revisiones están aprobadas y dictamen=1, se puede aprobar el trámite (opcional, según reglas).

## 4. Seguridad
- El usuario que realiza el cambio debe ser autenticado y autorizado (validar en el backend según reglas de negocio).
- Todas las entradas se validan en backend y frontend.

## 5. API eRequest/eResponse
- **Endpoint**: `/api/execute`
- **Método**: POST
- **Body**:
  ```json
  {
    "action": "changeEstatusRevision",
    "data": {
      "revision_id": 123,
      "nuevo_estatus": "A",
      "usuario": "jdoe",
      "fecha_revision": "2024-06-01",
      "oficio": "OF-123",
      "calificacion": 90,
      "costo": 1000.00,
      "fecha_consejo": "2024-06-10",
      "observacion": "Observaciones..."
    }
  }
  ```
- **Respuesta**:
  ```json
  {
    "success": true,
    "message": "",
    "data": { ... }
  }
  ```

## 6. Integración Vue.js
- El componente Vue es una página completa, sin tabs.
- Se conecta al endpoint `/api/execute` para todas las operaciones.
- Muestra mensajes de error y éxito.
- Valida campos requeridos según el estatus seleccionado.

## 7. Stored Procedures
- Toda la lógica de actualización y validación de negocio está en el SP `sp_cambiar_estatus_revision`.
- El SP actualiza las tablas `seg_revision`, `revisiones`, y `tramites` según reglas.
- El SP puede ser extendido para auditoría o bitácora.

## 8. Extensibilidad
- Se pueden agregar más acciones al endpoint `/api/execute` siguiendo el patrón eRequest/eResponse.
- El frontend puede ser extendido para otros formularios siguiendo el mismo patrón.

## 9. Manejo de Errores
- Todos los errores se devuelven en el campo `message` de la respuesta JSON.
- El frontend muestra los errores al usuario.

## 10. Consideraciones de Migración
- Los nombres de campos y lógica se adaptaron a convención snake_case y reglas de PostgreSQL.
- El SP asume que las tablas y campos existen y están correctamente relacionados.
- El frontend es responsivo y puede integrarse en cualquier SPA Vue.js.

## Casos de Prueba



## Casos de Uso

# Casos de Uso - estatusfrm

**Categoría:** Form

## Caso de Uso 1: Cambio de estatus a 'Pendiente' con prórroga

**Descripción:** Un usuario autorizado cambia el estatus de una revisión a 'Pendiente' y debe indicar la fecha de prórroga.

**Precondiciones:**
El usuario está autenticado y tiene permisos. La revisión está en estatus 'Vigente'.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de estatus.",
  "Selecciona 'Pendiente' como nuevo estatus.",
  "Ingresa la fecha de prórroga.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El estatus de la revisión cambia a 'Pendiente', se registra la fecha de prórroga y se inserta un nuevo registro en seg_revision.

**Datos de prueba:**
{
  "revision_id": 101,
  "nuevo_estatus": "P",
  "usuario": "admin",
  "fecha_revision": "2024-07-01",
  "oficio": "OF-2024-07",
  "observacion": "Se otorga prórroga por documentación incompleta."
}

---

## Caso de Uso 2: Cambio de estatus a 'Aprobado' con calificación y fecha de consejo

**Descripción:** Un usuario del comité de giros restringidos aprueba una revisión y debe registrar calificación, costo y fecha de consejo.

**Precondiciones:**
El usuario es del comité (dependencia 25 o 38). El giro es restringido (clasificación 'D'). El trámite es alta de licencia.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de estatus.",
  "Selecciona 'Aprobado' como nuevo estatus.",
  "Ingresa calificación, costo y fecha de consejo.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El estatus de la revisión cambia a 'Aprobado', se actualizan los campos calificación, costo y fecha de consejo en el trámite.

**Datos de prueba:**
{
  "revision_id": 202,
  "nuevo_estatus": "A",
  "usuario": "comite_user",
  "calificacion": 95,
  "costo": 1500.0,
  "fecha_consejo": "2024-07-10",
  "observacion": "Aprobado por comité."
}

---

## Caso de Uso 3: Intento de cambio de estatus a 'Cancelado' en revisión ya aprobada

**Descripción:** Un usuario intenta cancelar una revisión que ya está en estatus 'Aprobado'.

**Precondiciones:**
La revisión ya tiene estatus 'A'.

**Pasos a seguir:**
[
  "El usuario accede a la página de cambio de estatus.",
  "Selecciona 'Cancelado' como nuevo estatus.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El sistema rechaza el cambio y muestra el mensaje 'El estatus ya no se puede cambiar.'

**Datos de prueba:**
{
  "revision_id": 303,
  "nuevo_estatus": "C",
  "usuario": "admin"
}

---
