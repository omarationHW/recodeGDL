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

