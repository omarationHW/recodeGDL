# Casos de Uso - RptEmisionRbosAbastos

**Categoría:** Form

## Caso de Uso 1: Consulta de Recibos de Abastos para un Mercado y Periodo

**Descripción:** El usuario desea consultar el reporte de emisión de recibos de abastos para la oficina 5 (Cruz del Sur), mercado 1 (Abastos), año 2024 y periodo 6 (junio).

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos de adeudos para el mercado y periodo seleccionados.

**Pasos a seguir:**
- El usuario accede a la página 'Emisión de Recibos de Abastos'.
- Selecciona 'Cruz del Sur' en el campo Oficina.
- Selecciona 'Mercado Abastos' en el campo Mercado.
- Ingresa 2024 en el campo Año.
- Ingresa 6 en el campo Periodo.
- Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los locales, nombre, descripción, meses adeudados, renta, adeudo, recargos, subtotal y multa. Los totales se muestran al pie de la tabla.

**Datos de prueba:**
{ oficina: 5, mercado: 1, axo: 2024, periodo: 6 }

---

## Caso de Uso 2: Visualización de Requerimientos de un Local

**Descripción:** El usuario desea ver los requerimientos (apremios) asociados a un local específico desde el reporte.

**Precondiciones:**
El usuario ya consultó el reporte y hay al menos un local con requerimientos.

**Pasos a seguir:**
- El usuario hace clic en el botón 'Ver Requerimientos' en la fila de un local.
- Se abre un modal mostrando la lista de requerimientos asociados.

**Resultado esperado:**
El modal muestra una tabla con los folios, importe de multa, importe de gastos, fecha de emisión y observaciones de cada requerimiento.

**Datos de prueba:**
{ id_local: 12345 }

---

## Caso de Uso 3: Consulta de Recargos del Mes

**Descripción:** El sistema debe mostrar los recargos aplicables para un año y mes específico.

**Precondiciones:**
Existen registros de recargos en la tabla ta_12_recargos para el año y mes consultados.

**Pasos a seguir:**
- El frontend solicita los recargos del mes llamando a la acción 'getRecargosMes' con los parámetros axo=2024, mes=6.

**Resultado esperado:**
El backend responde con los datos de recargos para ese año y mes.

**Datos de prueba:**
{ axo: 2024, mes: 6 }

---

