# Casos de Uso - GAdeudos_OpcMult

**Categoría:** Form

## Caso de Uso 1: Registrar Pago de Adeudo de un Local

**Descripción:** El usuario busca un local por número y letra, selecciona los adeudos vigentes y ejecuta la opción 'Dar de Pagado'.

**Precondiciones:**
El usuario debe tener permisos para registrar pagos. El local debe existir y tener adeudos vigentes.

**Pasos a seguir:**
1. Ingresar el número de local y letra.
2. Hacer clic en 'Buscar'.
3. Seleccionar uno o varios adeudos en la tabla.
4. Ingresar los datos de pago (fecha, recaudadora, caja, consecutivo, folio recibo).
5. Seleccionar la opción 'Dar de Pagado'.
6. Hacer clic en 'Ejecutar'.

**Resultado esperado:**
El sistema registra el pago, actualiza el estado del adeudo y muestra un mensaje de éxito.

**Datos de prueba:**
localNum: '123', letra: 'A', fechaPagado: '2024-06-10', idRecaudadora: 1, caja: '1', consecOper: '1001', folioRcbo: 'RCB12345'

---

## Caso de Uso 2: Condonar Adeudo de una Concesión por Expediente

**Descripción:** El usuario busca una concesión por número de expediente, selecciona los adeudos y ejecuta la opción 'Condonar'.

**Precondiciones:**
El expediente debe existir y tener adeudos vigentes.

**Pasos a seguir:**
1. Ingresar el número de expediente.
2. Hacer clic en 'Buscar'.
3. Seleccionar los adeudos a condonar.
4. Seleccionar la opción 'Condonar'.
5. Hacer clic en 'Ejecutar'.

**Resultado esperado:**
El sistema condona los adeudos seleccionados y muestra un mensaje de éxito.

**Datos de prueba:**
numExpN: '456789', fechaPagado: '2024-06-10', idRecaudadora: 2, caja: '2', consecOper: '2002', folioRcbo: 'COND2024'

---

## Caso de Uso 3: Consultar Pagos Realizados de un Local

**Descripción:** El usuario busca un local y consulta el historial de pagos realizados.

**Precondiciones:**
El local debe existir y tener pagos registrados.

**Pasos a seguir:**
1. Ingresar el número de local y letra.
2. Hacer clic en 'Buscar'.
3. Hacer clic en el botón 'Pagados'.

**Resultado esperado:**
El sistema muestra la lista de pagos realizados para el local.

**Datos de prueba:**
localNum: '321', letra: 'B'

---

