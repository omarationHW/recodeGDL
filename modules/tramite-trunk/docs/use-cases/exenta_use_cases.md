# Casos de Uso - exenta

**Categoría:** Form

## Caso de Uso 1: Registrar una Exención a una Cuenta Vigente

**Descripción:** El usuario desea registrar una exención de pago predial para una cuenta catastral vigente que actualmente no tiene exención.

**Precondiciones:**
El usuario está autenticado y tiene permisos. La cuenta no tiene abstención ni exención activa.

**Pasos a seguir:**
- El usuario accede a la página de exenciones e ingresa el número de cuenta.
- El sistema muestra los datos del predio y propietario.
- El usuario ingresa el año de efectos (ej. 2024), bimestre (ej. 2) y una observación.
- El usuario hace clic en 'Registrar Exención'.
- El sistema valida los datos y ejecuta el SP correspondiente.

**Resultado esperado:**
La exención se registra correctamente. El estado de exención cambia a 'S'. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "axoefec": 2024, "bimefec": 2, "observacion": "Exención por ley especial" }

---

## Caso de Uso 2: Eliminar una Exención Existente

**Descripción:** El usuario desea eliminar una exención previamente registrada en una cuenta.

**Precondiciones:**
El usuario está autenticado. La cuenta tiene exención activa y no tiene abstención.

**Pasos a seguir:**
- El usuario accede a la página de exenciones e ingresa el número de cuenta.
- El sistema muestra los datos y detecta que la cuenta está exenta.
- El usuario ingresa el año y bimestre de efectos y una observación.
- El usuario hace clic en 'Eliminar Exención'.
- El sistema ejecuta el SP de eliminación.

**Resultado esperado:**
La exención se elimina correctamente. El estado de exención cambia a 'N'. Se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "axoefec": 2024, "bimefec": 2, "observacion": "Fin de exención" }

---

## Caso de Uso 3: Intentar Registrar Exención en Cuenta con Abstención

**Descripción:** El usuario intenta registrar una exención en una cuenta que tiene abstención de movimientos.

**Precondiciones:**
La cuenta tiene cvemov=12 (abstención).

**Pasos a seguir:**
- El usuario accede a la página de exenciones e ingresa el número de cuenta.
- El sistema detecta la abstención.
- El usuario intenta registrar la exención.
- El sistema rechaza la operación.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'CUENTA CON ABSTENCION. NO SE PUEDE EXENTAR'.

**Datos de prueba:**
{ "cvecuenta": 99999, "axoefec": 2024, "bimefec": 2, "observacion": "Intento inválido" }

---

