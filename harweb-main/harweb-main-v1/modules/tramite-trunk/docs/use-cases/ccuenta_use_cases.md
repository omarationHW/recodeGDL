# Casos de Uso - ccuenta

**Categoría:** Form

## Caso de Uso 1: Cancelación exitosa de cuenta vigente

**Descripción:** Un usuario autorizado cancela una cuenta catastral vigente por motivo de duplicidad.

**Precondiciones:**
La cuenta existe y está en estado vigente ('V'). El usuario tiene permisos.

**Pasos a seguir:**
1. El usuario accede a la página de cancelación e ingresa el número de cuenta.
2. El sistema muestra los datos de la cuenta y sus valores.
3. El usuario hace clic en 'Cancelar cuenta'.
4. El sistema muestra el formulario de motivo y observación.
5. El usuario ingresa el motivo 'Duplicidad' y una observación.
6. El usuario confirma la cancelación.
7. El sistema ejecuta el stored procedure y actualiza el estado.

**Resultado esperado:**
La cuenta queda marcada como cancelada, se registra el movimiento y se recalculan los saldos.

**Datos de prueba:**
{ "cvecuenta": 12345, "motivo": "Duplicidad", "observacion": "Cuenta duplicada por error de captura", "usuario": "admin" }

---

## Caso de Uso 2: Intento de cancelar cuenta ya cancelada

**Descripción:** Un usuario intenta cancelar una cuenta que ya está cancelada.

**Precondiciones:**
La cuenta existe y está en estado cancelada ('C').

**Pasos a seguir:**
1. El usuario accede a la página de cancelación e ingresa el número de cuenta.
2. El sistema muestra los datos y advierte que la cuenta ya está cancelada.
3. El botón 'Cancelar cuenta' está deshabilitado.

**Resultado esperado:**
No se permite cancelar la cuenta, se muestra mensaje de error.

**Datos de prueba:**
{ "cvecuenta": 54321 }

---

## Caso de Uso 3: Cancelación con requerimientos vigentes

**Descripción:** Un usuario cancela una cuenta que tiene requerimientos prediales vigentes.

**Precondiciones:**
La cuenta está vigente y tiene registros en reqpredial con vigencia 'V' y cvepago IS NULL.

**Pasos a seguir:**
1. El usuario accede a la página de cancelación.
2. El sistema muestra los datos y advierte sobre requerimientos vigentes.
3. El usuario confirma la cancelación.
4. El stored procedure cancela los requerimientos y recalcula saldos.

**Resultado esperado:**
La cuenta queda cancelada, los requerimientos se marcan como cancelados y los saldos se actualizan.

**Datos de prueba:**
{ "cvecuenta": 67890, "motivo": "Inactividad", "observacion": "Cuenta sin movimiento desde 2010", "usuario": "admin" }

---

