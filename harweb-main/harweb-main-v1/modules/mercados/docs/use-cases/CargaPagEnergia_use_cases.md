# Casos de Uso - CargaPagEnergia

**Categoría:** Form

## Caso de Uso 1: Carga de Pago de Energía para un Local

**Descripción:** El usuario busca los adeudos de energía eléctrica de un local y realiza el pago de uno o varios adeudos.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cargar pagos. Debe existir al menos un adeudo pendiente para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Selecciona la recaudadora, mercado, sección y local.
3. Hace clic en 'Buscar Adeudos'.
4. El sistema muestra los adeudos pendientes.
5. El usuario selecciona uno o varios adeudos.
6. Ingresa los datos del pago (fecha, oficina de pago, caja, operación, folio).
7. Hace clic en 'Cargar Pagos'.
8. El sistema registra los pagos y elimina los adeudos correspondientes.

**Resultado esperado:**
Los pagos quedan registrados y los adeudos seleccionados desaparecen de la lista de pendientes.

**Datos de prueba:**
oficina: 5, mercado: 1, categoria: 2, seccion: 'SS', local: 123, fecha_pago: '2024-06-10', oficina_pago: 5, caja_pago: 'A', operacion_pago: 12345, folio: 'FOL123'

---

## Caso de Uso 2: Consulta de Pagos Realizados

**Descripción:** El usuario consulta los pagos realizados para un local/energía.

**Precondiciones:**
El usuario debe estar autenticado. Debe existir al menos un pago registrado para el id_energia consultado.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Realiza una búsqueda de adeudos y/o pagos.
3. Hace clic en 'Consultar Pagos' para un id_energia.
4. El sistema muestra la lista de pagos realizados.

**Resultado esperado:**
Se muestra la lista de pagos realizados para el id_energia seleccionado.

**Datos de prueba:**
id_energia: 1001

---

## Caso de Uso 3: Validación de Campos Requeridos

**Descripción:** El usuario intenta cargar pagos sin seleccionar ningún adeudo o sin completar los datos requeridos.

**Precondiciones:**
El usuario debe estar autenticado. Debe haber adeudos listados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía.
2. Busca adeudos para un local.
3. No selecciona ningún adeudo y hace clic en 'Cargar Pagos'.
4. El sistema muestra un mensaje de error.
5. El usuario selecciona adeudos pero omite algún campo obligatorio (ej. fecha de pago).
6. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema no permite cargar pagos y muestra mensajes de error claros.

**Datos de prueba:**
oficina: 5, mercado: 1, categoria: 2, seccion: 'SS', local: 123, pagos: [], fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '', folio: ''

---

