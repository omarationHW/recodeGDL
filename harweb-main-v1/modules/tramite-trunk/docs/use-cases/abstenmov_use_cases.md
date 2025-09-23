# Casos de Uso - abstenmov

**Categoría:** Form

## Caso de Uso 1: Registrar abstención de movimientos en una cuenta vigente

**Descripción:** El usuario desea registrar una abstención de movimientos para una cuenta catastral activa.

**Precondiciones:**
La cuenta catastral existe y está vigente (no cancelada). No existe una abstención activa.

**Pasos a seguir:**
- El usuario accede a la página de abstención para la cuenta.
- Visualiza los datos del predio y propietario.
- Ingresa el año de efectos, bimestre y una observación.
- Presiona 'Registrar Abstención'.
- El sistema valida y registra la abstención.

**Resultado esperado:**
La abstención queda registrada, los campos quedan bloqueados y aparece el mensaje 'La abstención ha sido registrada'.

**Datos de prueba:**
{ "cvecuenta": 1001, "axoefec": 2024, "bimefec": 2, "observacion": "Por solicitud del propietario.", "usuario": "admin" }

---

## Caso de Uso 2: Eliminar abstención de movimientos existente

**Descripción:** El usuario desea eliminar una abstención previamente registrada.

**Precondiciones:**
La cuenta catastral tiene una abstención activa (cvemov=12).

**Pasos a seguir:**
- El usuario accede a la página de abstención para la cuenta.
- Visualiza que la abstención está activa.
- Presiona 'Eliminar Abstención'.
- El sistema valida y elimina la abstención.

**Resultado esperado:**
La abstención es eliminada, los campos quedan habilitados y aparece el mensaje 'La abstención ha sido eliminada.'

**Datos de prueba:**
{ "cvecuenta": 1001, "axoefec": 2024, "bimefec": 2, "observacion": "Se reactivan movimientos.", "usuario": "admin" }

---

## Caso de Uso 3: Intentar registrar abstención en cuenta cancelada

**Descripción:** El usuario intenta registrar una abstención en una cuenta que está cancelada.

**Precondiciones:**
La cuenta catastral existe pero su campo 'vigente' es 'C'.

**Pasos a seguir:**
- El usuario accede a la página de abstención para la cuenta.
- Ingresa los datos y presiona 'Registrar Abstención'.
- El sistema valida y rechaza la operación.

**Resultado esperado:**
El sistema muestra el mensaje de error 'Esta cuenta está cancelada, la abstención no es posible!' y no realiza ningún cambio.

**Datos de prueba:**
{ "cvecuenta": 2002, "axoefec": 2024, "bimefec": 2, "observacion": "Intento en cuenta cancelada.", "usuario": "admin" }

---

