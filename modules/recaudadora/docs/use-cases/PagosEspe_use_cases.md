# Casos de Uso - PagosEspe

**Categoría:** Form

## Caso de Uso 1: Autorización de Pago Especial Exitosa

**Descripción:** Un usuario autorizado ingresa los datos de un pago especial para una cuenta activa y lo autoriza correctamente.

**Precondiciones:**
La cuenta catastral existe, está activa y no tiene pagos especiales vigentes.

**Pasos a seguir:**
- El usuario accede a la página de Pagos Especiales.
- Ingresa el número de cuenta, bimestre inicial/final y año inicial/final.
- Presiona 'Autorizar Pago Especial'.

**Resultado esperado:**
El sistema autoriza el pago especial, lo registra en la base de datos y lo muestra en la lista como 'VIGENTE'.

**Datos de prueba:**
{
  "cvecuenta": 12345,
  "bimini": 1,
  "axoini": 2023,
  "bimfin": 2,
  "axofin": 2023
}

---

## Caso de Uso 2: Intento de Autorización con Cuenta Exenta

**Descripción:** Un usuario intenta autorizar un pago especial para una cuenta marcada como exenta.

**Precondiciones:**
La cuenta catastral existe y está marcada como exenta en la base de datos.

**Pasos a seguir:**
- El usuario accede a la página de Pagos Especiales.
- Ingresa el número de cuenta exenta y los datos del pago especial.
- Presiona 'Autorizar Pago Especial'.

**Resultado esperado:**
El sistema rechaza la operación y muestra el mensaje 'Cuenta exenta. No puede usar esta opción'.

**Datos de prueba:**
{
  "cvecuenta": 54321,
  "bimini": 1,
  "axoini": 2023,
  "bimfin": 2,
  "axofin": 2023
}

---

## Caso de Uso 3: Cancelación de Pago Especial Vigente

**Descripción:** Un usuario cancela un pago especial que está vigente (no pagado ni cancelado).

**Precondiciones:**
Existe un registro en autpagoesp con cvepago IS NULL para la cuenta.

**Pasos a seguir:**
- El usuario accede a la página de Pagos Especiales.
- Visualiza la lista de pagos especiales.
- Presiona 'Cancelar' en un pago especial vigente.

**Resultado esperado:**
El sistema marca el pago especial como cancelado (cvepago=999999) y lo muestra como 'CANCELADO' en la lista.

**Datos de prueba:**
{
  "cveaut": 1001
}

---

