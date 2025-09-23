# Casos de Uso - auttranspatfrm

**Categoría:** Form

## Caso de Uso 1: Registrar nueva autorización de transmisión patrimonial

**Descripción:** Un usuario captura una nueva autorización de transmisión patrimonial, indicando si causa impuesto, justificación legal y si aplica tasa preferencial.

**Precondiciones:**
El usuario está autenticado y tiene permisos para registrar transmisiones. El folio no existe previamente.

**Pasos a seguir:**
[
  "El usuario accede a la página de Autorización de Transmisión Patrimonial.",
  "Llena el formulario con los datos requeridos: folio, exento, justificación legal, tasa preferencial.",
  "Presiona el botón 'Guardar'.",
  "El sistema valida los datos y guarda el registro en la base de datos.",
  "El sistema muestra mensaje de éxito y actualiza el historial."
]

**Resultado esperado:**
El registro se guarda correctamente y aparece en el historial.

**Datos de prueba:**
{
  "folio": 12345,
  "exento": "N",
  "documentos_otros": "Justificación legal ejemplo",
  "justificacion": "Observaciones adicionales",
  "tasa_preferencial": "S",
  "usuario": "jdoe"
}

---

## Caso de Uso 2: Autorizar transmisión patrimonial para pago

**Descripción:** Un usuario autoriza una transmisión patrimonial previamente registrada, cambiando su status a 'P'.

**Precondiciones:**
Existe un registro con status 'A' y folio conocido.

**Pasos a seguir:**
[
  "El usuario busca el folio en la página.",
  "Verifica los datos y presiona el botón 'Autorizar'.",
  "El sistema ejecuta el SP de autorización y cambia el status a 'P'.",
  "El sistema muestra mensaje de éxito y actualiza el historial."
]

**Resultado esperado:**
El registro cambia a status 'P' y no puede ser editado.

**Datos de prueba:**
{
  "folio": 12345,
  "usuario": "jdoe"
}

---

## Caso de Uso 3: Cerrar y reabrir transmisión patrimonial

**Descripción:** Un usuario cierra una transmisión patrimonial (status 'C') y posteriormente la reabre (status 'A').

**Precondiciones:**
Existe un registro con status 'P'.

**Pasos a seguir:**
[
  "El usuario busca el folio y presiona 'Cerrar'.",
  "El sistema cambia el status a 'C'.",
  "El usuario presiona 'Reabrir'.",
  "El sistema cambia el status a 'A'."
]

**Resultado esperado:**
El registro pasa de 'P' a 'C' y luego a 'A'.

**Datos de prueba:**
{
  "folio": 12345,
  "usuario": "jdoe"
}

---

