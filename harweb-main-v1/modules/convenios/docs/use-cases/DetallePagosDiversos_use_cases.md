# Casos de Uso - DetallePagosDiversos

**Categoría:** Form

## Caso de Uso 1: Consulta de Detalle de Pagos Diversos por Convenio

**Descripción:** El usuario desea consultar todos los pagos realizados para un convenio/resto específico y ver el desgloce de cada pago.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. Existe al menos un convenio con pagos registrados.

**Pasos a seguir:**
1. El usuario accede a la página 'Detalle de Pagos Diversos'.
2. Ingresa el ID del convenio/resto (por ejemplo, 12345) y presiona 'Buscar'.
3. El sistema consulta el endpoint /api/execute con action=getPagosDiversosDetalle y muestra la tabla de pagos.
4. El usuario revisa los pagos y hace clic en 'Ver' en la columna Desgloce de un pago.
5. Se abre un modal mostrando el desgloce de cuentas para ese pago.

**Resultado esperado:**
Se muestra la lista de pagos con sus detalles y el desgloce de cuentas correspondiente al pago seleccionado.

**Datos de prueba:**
id_conv_resto: 12345 (debe existir en la base de datos con pagos asociados)

---

## Caso de Uso 2: Visualización de Totales de Pagos, Recargos e Intereses

**Descripción:** El usuario requiere ver el total acumulado de pagos, recargos e intereses para un convenio/resto.

**Precondiciones:**
El usuario está autenticado. El convenio/resto tiene pagos registrados.

**Pasos a seguir:**
1. El usuario ingresa el ID del convenio/resto y presiona 'Buscar'.
2. El sistema consulta los pagos y automáticamente calcula y muestra los totales en la sección inferior.

**Resultado esperado:**
Los totales de pagos, recargos e intereses se muestran correctamente sumados.

**Datos de prueba:**
id_conv_resto: 12345 (con al menos 2 pagos, cada uno con recargos e intereses distintos)

---

## Caso de Uso 3: Error por Convenio/Resto Inexistente

**Descripción:** El usuario intenta consultar un convenio/resto que no existe.

**Precondiciones:**
El usuario está autenticado. El ID ingresado no existe en la base de datos.

**Pasos a seguir:**
1. El usuario ingresa un ID inválido (por ejemplo, 999999) y presiona 'Buscar'.
2. El sistema consulta el endpoint y recibe un error.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el convenio/resto no existe o no tiene pagos.

**Datos de prueba:**
id_conv_resto: 999999 (no debe existir en la base de datos)

---

