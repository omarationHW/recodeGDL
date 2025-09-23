# Casos de Uso - Pagos_Cons_Cont

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un contrato existente

**Descripción:** El usuario consulta los pagos realizados para un contrato y tipo de aseo válidos.

**Precondiciones:**
El contrato y tipo de aseo existen y tienen pagos con status 'P'.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos por Contrato.
2. Ingresa el número de contrato (ej: 1803).
3. Selecciona el tipo de aseo correspondiente (ej: 8 - Ordinario).
4. Presiona el botón 'Buscar'.
5. El sistema muestra la lista de pagos asociados.

**Resultado esperado:**
Se muestra una tabla con los pagos del contrato, incluyendo periodo, operación, importe, status, fecha de pago, etc.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---

## Caso de Uso 2: Intento de consulta con contrato inexistente

**Descripción:** El usuario intenta consultar pagos para un contrato que no existe.

**Precondiciones:**
El número de contrato no existe en la base de datos.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa un número de contrato inexistente (ej: 999999).
3. Selecciona cualquier tipo de aseo.
4. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error: 'No existe contrato, intenta con otro.'

**Datos de prueba:**
contrato: 999999, ctrol_aseo: 8

---

## Caso de Uso 3: Descarga de Edo. de Cuenta en PDF

**Descripción:** El usuario descarga el estado de cuenta en PDF para un contrato válido.

**Precondiciones:**
El contrato existe y tiene pagos.

**Pasos a seguir:**
1. El usuario realiza una búsqueda exitosa de pagos.
2. Presiona el botón 'Edo. de Cuenta'.
3. El sistema genera el PDF y lo muestra/descarga.

**Resultado esperado:**
Se abre el PDF del Edo. de Cuenta en una nueva ventana/pestaña.

**Datos de prueba:**
contrato: 1803, ctrol_aseo: 8

---

