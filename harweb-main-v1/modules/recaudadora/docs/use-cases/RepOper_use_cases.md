# Casos de Uso - RepOper

**Categoría:** Form

## Caso de Uso 1: Consulta de Totales de Operaciones

**Descripción:** El usuario desea conocer los totales de operaciones (canceladas, cheques, efectivo, etc.) para una caja, recaudadora y fecha específica.

**Precondiciones:**
Existen registros en las tablas pagos y cheqpag para la fecha, recaudadora y caja seleccionadas.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Operaciones por Caja.
2. Selecciona la fecha de ingreso.
3. Selecciona la recaudadora (por ejemplo, '1').
4. El sistema carga las cajas disponibles para esa fecha y recaudadora.
5. El usuario selecciona una caja.
6. El usuario hace clic en el botón 'Totales'.
7. El sistema muestra los totales de operaciones.

**Resultado esperado:**
Se muestran los totales de operaciones correctamente calculados para la selección dada.

**Datos de prueba:**
fecha: '2024-06-01', recaud: '1', caja: 'A'

---

## Caso de Uso 2: Consulta de Desglose de Operaciones

**Descripción:** El usuario requiere ver el detalle de todas las operaciones realizadas en una caja, recaudadora y fecha.

**Precondiciones:**
Existen operaciones registradas en pagos y auditoria para la combinación seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Listado de Operaciones por Caja.
2. Selecciona la fecha de ingreso.
3. Selecciona la recaudadora.
4. El sistema carga las cajas disponibles.
5. El usuario selecciona una caja.
6. El usuario hace clic en el botón 'Desglose'.
7. El sistema muestra el listado detallado de operaciones.

**Resultado esperado:**
Se muestra una tabla con el detalle de cada operación (folio, cuenta, importe, mensaje, etc.).

**Datos de prueba:**
fecha: '2024-06-01', recaud: '2', caja: 'B'

---

## Caso de Uso 3: Carga dinámica de cajas por fecha y recaudadora

**Descripción:** El usuario selecciona una fecha y recaudadora, y el sistema debe mostrar solo las cajas disponibles para esa combinación.

**Precondiciones:**
Existen registros en pagos para varias cajas en la fecha y recaudadora seleccionadas.

**Pasos a seguir:**
1. El usuario accede al formulario.
2. Selecciona una fecha.
3. Selecciona una recaudadora.
4. El sistema consulta y muestra las cajas disponibles en el combo de cajas.

**Resultado esperado:**
El combo de cajas muestra solo las cajas válidas para la fecha y recaudadora seleccionadas.

**Datos de prueba:**
fecha: '2024-06-01', recaud: '3'

---

