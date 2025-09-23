# Casos de Uso - SdosFavor_Pagos

**Categoría:** Form

## Caso de Uso 1: Registrar un nuevo pago a favor

**Descripción:** El usuario ingresa los datos de un nuevo pago y lo guarda.

**Precondiciones:**
No debe existir un pago con la misma combinación de reca, caja y folio.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Ingresar 'importe': '1500.00'",
  "Seleccionar 'fecha': '2024-06-10'",
  "Presionar 'Guardar'"
]

**Resultado esperado:**
El pago se registra correctamente y aparece en la tabla de pagos.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123",
  "importe": "1500.00",
  "fecha": "2024-06-10"
}

---

## Caso de Uso 2: Editar un pago existente

**Descripción:** El usuario localiza un pago existente, modifica el importe y guarda los cambios.

**Precondiciones:**
Debe existir un pago con reca='101', caja='01', folio='000123'.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Presionar 'Localizar Pago'",
  "Modificar 'importe' a '2000.00'",
  "Presionar 'Guardar'"
]

**Resultado esperado:**
El importe del pago se actualiza y se refleja en la tabla.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123",
  "importe": "2000.00",
  "fecha": "2024-06-10"
}

---

## Caso de Uso 3: Eliminar un pago a favor

**Descripción:** El usuario localiza un pago y lo elimina.

**Precondiciones:**
Debe existir un pago con reca='101', caja='01', folio='000123'.

**Pasos a seguir:**
[
  "Ingresar 'reca': '101'",
  "Ingresar 'caja': '01'",
  "Ingresar 'folio': '000123'",
  "Presionar 'Localizar Pago'",
  "Presionar 'Eliminar'",
  "Confirmar la eliminación"
]

**Resultado esperado:**
El pago se elimina y ya no aparece en la tabla.

**Datos de prueba:**
{
  "reca": "101",
  "caja": "01",
  "folio": "000123"
}

---

