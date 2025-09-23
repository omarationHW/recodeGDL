# Casos de Uso - investctafrm

**Categoría:** Form

## Caso de Uso 1: Registrar investigación de cuenta con observación

**Descripción:** El usuario registra una observación de investigación para una cuenta catastral existente.

**Precondiciones:**
El usuario está autenticado y conoce el número de cuenta catastral.

**Pasos a seguir:**
- El usuario accede a la página de Investigación de Cuentas.
- Ingresa el número de cuenta catastral (ej: 12345).
- El sistema muestra los datos del último comprobante.
- El usuario escribe una observación en el campo correspondiente.
- El usuario presiona 'Actualizar'.

**Resultado esperado:**
La observación se guarda, el movimiento se registra como investigación (cvemov=73), el asiento se incrementa y se muestra mensaje de éxito.

**Datos de prueba:**
{ "cvecuenta": 12345, "observacion": "CUENTA EN INVESTIGACION POR INCONSISTENCIA DE DATOS" }

---

## Caso de Uso 2: Intentar actualizar una cuenta inexistente

**Descripción:** El usuario intenta registrar una observación para una cuenta que no existe.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- El usuario accede a la página de Investigación de Cuentas.
- Ingresa un número de cuenta inexistente (ej: 999999).
- El sistema muestra mensaje de error indicando que la cuenta no existe.

**Resultado esperado:**
No se realiza ninguna actualización y se muestra mensaje de error.

**Datos de prueba:**
{ "cvecuenta": 999999, "observacion": "PRUEBA ERROR" }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta guardar sin llenar todos los campos obligatorios.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- El usuario accede a la página de Investigación de Cuentas.
- Deja vacío el campo de observaciones.
- Presiona 'Actualizar'.

**Resultado esperado:**
El sistema muestra mensaje de error indicando que todos los campos son obligatorios.

**Datos de prueba:**
{ "cvecuenta": 12345, "observacion": "" }

---

