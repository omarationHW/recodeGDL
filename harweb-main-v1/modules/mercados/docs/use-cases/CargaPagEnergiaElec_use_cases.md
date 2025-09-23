# Casos de Uso - CargaPagEnergiaElec

**Categoría:** Form

## Caso de Uso 1: Carga de Pagos de Energía Eléctrica para un Local

**Descripción:** El usuario consulta los adeudos de energía eléctrica de un local y realiza la carga de pagos correspondientes.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para cargar pagos. Debe existir al menos un adeudo pendiente para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Selecciona la recaudadora, mercado, categoría, sección y rango de locales.
3. Hace clic en 'Buscar Adeudos'.
4. El sistema muestra la lista de adeudos pendientes.
5. El usuario selecciona los adeudos a pagar y captura la partida.
6. Captura los datos del pago (fecha, oficina, caja, operación).
7. Hace clic en 'Cargar Pagos'.
8. El sistema valida y ejecuta la carga de pagos.
9. El sistema muestra mensaje de éxito y actualiza la lista de adeudos.

**Resultado esperado:**
Los pagos seleccionados se registran correctamente y los adeudos correspondientes se eliminan. El usuario ve un mensaje de éxito.

**Datos de prueba:**
oficina: 2, mercado: 5, categoria: 1, seccion: 'A', local_desde: 10, local_hasta: 10, fecha_pago: '2024-06-10', oficina_pago: 2, caja_pago: 'A1', operacion_pago: 12345, pagos: [{ id_energia: 123, axo: 2024, periodo: 6, importe: 150.00, cve_consumo: 'F', cantidad: 100, folio: '12345' }]

---

## Caso de Uso 2: Consulta de Pagos Realizados para un Local

**Descripción:** El usuario consulta los pagos realizados para un local específico.

**Precondiciones:**
El usuario debe estar autenticado. Debe existir al menos un pago registrado para el local.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Busca los adeudos de un local y selecciona uno.
3. Hace clic en 'Consultar Pagos'.
4. El sistema muestra la lista de pagos realizados para ese local.

**Resultado esperado:**
El usuario visualiza la lista de pagos realizados para el local seleccionado.

**Datos de prueba:**
id_energia: 123

---

## Caso de Uso 3: Validación de Campos Obligatorios al Cargar Pagos

**Descripción:** El usuario intenta cargar pagos sin capturar la partida o sin seleccionar adeudos.

**Precondiciones:**
El usuario debe estar autenticado. Debe haber adeudos listados.

**Pasos a seguir:**
1. El usuario accede a la página de Carga de Pagos de Energía Eléctrica.
2. Busca los adeudos de un local.
3. Intenta cargar pagos sin seleccionar ningún adeudo o sin capturar la partida.
4. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema no permite cargar pagos y muestra un mensaje de error indicando que debe seleccionar al menos un adeudo y capturar la partida.

**Datos de prueba:**
pagos: []

---

