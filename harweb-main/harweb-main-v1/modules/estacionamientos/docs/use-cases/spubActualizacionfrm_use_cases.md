# Casos de Uso - spubActualizacionfrm

**Categoría:** Form

## Caso de Uso 1: Modificación de Estacionamiento Público

**Descripción:** El usuario busca un estacionamiento por número, visualiza sus datos y realiza una modificación (por ejemplo, cambia el teléfono o la calle).

**Precondiciones:**
El usuario debe estar autenticado. El estacionamiento debe existir.

**Pasos a seguir:**
1. Acceder a la página de modificación.
2. Ingresar el número de estacionamiento y presionar 'Buscar'.
3. Visualizar los datos actuales.
4. Modificar el campo 'Teléfono'.
5. Presionar 'Actualizar'.

**Resultado esperado:**
El sistema actualiza los datos y muestra un mensaje de éxito. Al volver a buscar, los datos modificados aparecen reflejados.

**Datos de prueba:**
{ "numesta": 101, "telefono": "3312345678" }

---

## Caso de Uso 2: Baja de Estacionamiento Público

**Descripción:** El usuario da de baja un estacionamiento existente, registrando el folio y la fecha de baja.

**Precondiciones:**
El usuario debe estar autenticado. El estacionamiento debe existir y estar vigente.

**Pasos a seguir:**
1. Acceder a la página de bajas.
2. Ingresar el número de estacionamiento y buscar.
3. Ingresar el folio y la fecha de baja.
4. Presionar 'Baja'.

**Resultado esperado:**
El sistema marca el estacionamiento como dado de baja y muestra un mensaje de éxito.

**Datos de prueba:**
{ "id": 101, "folio": 555, "fecbaja": "2024-06-01" }

---

## Caso de Uso 3: Aplicación de Pago a Adeudo

**Descripción:** El usuario aplica un pago a un adeudo específico de un estacionamiento.

**Precondiciones:**
El usuario debe estar autenticado. Debe existir un adeudo pendiente para el estacionamiento.

**Pasos a seguir:**
1. Acceder a la página de adeudos.
2. Buscar el estacionamiento y visualizar los adeudos.
3. Seleccionar un adeudo y presionar 'Aplicar Pago'.
4. Ingresar los datos del pago (fecha, oficina, caja, operación).
5. Confirmar la aplicación del pago.

**Resultado esperado:**
El sistema registra el pago y actualiza el estado del adeudo.

**Datos de prueba:**
{ "pubmain_id": 101, "axo": 2024, "mes": 5, "tipo": 10, "fecha": "2024-06-01", "reca": 4, "caja": "A1", "operacion": 123456 }

---

