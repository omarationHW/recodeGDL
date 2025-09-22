# Casos de Uso - bloqueoRFCfrm

**Categoría:** Form

## Caso de Uso 1: Bloquear un RFC por incumplimiento

**Descripción:** Un usuario de Padron y Licencias detecta que un contribuyente incumplió el programa de autoevaluación y procede a bloquear su RFC.

**Precondiciones:**
El usuario está autenticado y tiene permisos para bloquear RFC. El RFC no debe estar ya bloqueado (vigente).

**Pasos a seguir:**
[
  "El usuario accede a la página de Bloqueo de RFC.",
  "Hace clic en 'Agregar Bloqueo'.",
  "Teclea el ID de trámite y usa 'Buscar' para autollenar los datos.",
  "Verifica que el RFC, licencia, propietario y actividad sean correctos.",
  "Escribe el motivo del bloqueo.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El RFC queda bloqueado (vigente) y aparece en la lista. No se permite bloquear dos veces el mismo RFC vigente.

**Datos de prueba:**
{
  "id_tramite": 12345,
  "licencia": 54321,
  "rfc": "ABC123456XYZ",
  "observacion": "Incumplimiento autoevaluación"
}

---

## Caso de Uso 2: Desbloquear un RFC

**Descripción:** Un usuario autorizado decide desbloquear un RFC previamente bloqueado.

**Precondiciones:**
El RFC debe estar bloqueado (vigente).

**Pasos a seguir:**
[
  "El usuario busca el RFC en la tabla.",
  "Hace clic en 'Desbloquear'.",
  "Edita o confirma el motivo.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El RFC cambia su vigencia a 'C' (cancelado) y ya no aparece como vigente.

**Datos de prueba:**
{
  "rfc": "ABC123456XYZ",
  "observacion": "Se regularizó la situación"
}

---

## Caso de Uso 3: Editar el motivo de un bloqueo vigente

**Descripción:** El usuario necesita actualizar el motivo de un bloqueo vigente.

**Precondiciones:**
El RFC está bloqueado (vigente).

**Pasos a seguir:**
[
  "El usuario busca el RFC en la tabla.",
  "Hace clic en 'Editar'.",
  "Modifica el campo 'Motivo'.",
  "Hace clic en 'Aceptar'."
]

**Resultado esperado:**
El motivo se actualiza correctamente y la fecha/hora se actualiza.

**Datos de prueba:**
{
  "rfc": "ABC123456XYZ",
  "observacion": "Motivo actualizado"
}

---

