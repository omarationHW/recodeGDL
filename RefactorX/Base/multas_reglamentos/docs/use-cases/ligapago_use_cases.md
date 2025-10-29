# Casos de Uso - ligapago

**Categoría:** Form

## Caso de Uso 1: Ligar pago a requerimiento predial

**Descripción:** Un usuario selecciona una cuenta catastral, elige un pago disponible y lo liga a un folio de requerimiento predial pendiente.

**Precondiciones:**
La cuenta debe estar vigente y no exenta. Debe existir al menos un pago pendiente de ligar.

**Pasos a seguir:**
1. El usuario ingresa el número de cuenta catastral.
2. El sistema muestra los pagos disponibles.
3. El usuario selecciona un pago y elige 'Ligar'.
4. El usuario confirma los datos y envía el formulario.
5. El sistema valida el estado de la cuenta y ejecuta el stored procedure.

**Resultado esperado:**
El pago queda ligado al folio de requerimiento predial y se actualiza la base de datos.

**Datos de prueba:**
{ "cvecuenta": 1001, "cvepago": 2001, "usuario": "admin", "tipo": 2 }

---

## Caso de Uso 2: Ligar pago a folio de transmisión patrimonial

**Descripción:** Un usuario liga un pago a un folio de transmisión patrimonial existente.

**Precondiciones:**
La cuenta debe estar vigente y no exenta. El folio de transmisión debe existir y estar pendiente de pago.

**Pasos a seguir:**
1. El usuario ingresa la cuenta catastral.
2. El sistema muestra los pagos disponibles.
3. El usuario selecciona un pago y elige 'Ligar'.
4. El usuario selecciona el tipo 'Transmisión Patrimonial' y proporciona el folio de transmisión.
5. El usuario confirma y envía el formulario.
6. El sistema ejecuta el stored procedure correspondiente.

**Resultado esperado:**
El pago queda ligado al folio de transmisión patrimonial.

**Datos de prueba:**
{ "cvecuenta": 1002, "cvepago": 2002, "usuario": "admin", "tipo": 22, "folio": 3001 }

---

## Caso de Uso 3: Intento de ligar pago a cuenta exenta

**Descripción:** El usuario intenta ligar un pago a una cuenta marcada como exenta.

**Precondiciones:**
La cuenta debe tener el campo exento = 'S'.

**Pasos a seguir:**
1. El usuario ingresa la cuenta catastral exenta.
2. El sistema muestra mensaje de error y no permite continuar.

**Resultado esperado:**
El sistema rechaza la operación y muestra el mensaje 'Cuenta exenta. No puede usar esta opción'.

**Datos de prueba:**
{ "cvecuenta": 9999, "cvepago": 8888, "usuario": "admin", "tipo": 2 }

---

