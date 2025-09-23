# Casos de Uso - Multiplefecha

**Categoría:** Form

## Caso de Uso 1: Consulta de Pagos y Títulos por Fecha

**Descripción:** El usuario desea ver todos los pagos y títulos realizados el 2024-06-01 en la recaudadora 1 y caja 'A'.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros para esa fecha.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta Múltiple por Fecha de Pago'.
2. Ingresa la fecha '2024-06-01', recaudadora '1', caja 'A'.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la tabla con todos los pagos y títulos encontrados.

**Resultado esperado:**
Se listan todos los pagos y títulos del 2024-06-01, recaudadora 1, caja 'A'.

**Datos de prueba:**
{ "fecha": "2024-06-01", "rec": 1, "caja": "A" }

---

## Caso de Uso 2: Consulta Detalle Individual de un Pago

**Descripción:** El usuario desea ver el detalle de un pago específico desde la lista.

**Precondiciones:**
El usuario ya realizó una búsqueda y hay resultados en la tabla.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver Detalle' en la fila de un pago con folio 12345.
2. El sistema consulta el detalle individual y lo muestra en un modal.

**Resultado esperado:**
Se muestra toda la información detallada del pago con control_rcm 12345.

**Datos de prueba:**
{ "control_rcm": 12345 }

---

## Caso de Uso 3: Manejo de Error: Fecha sin registros

**Descripción:** El usuario consulta una fecha donde no existen pagos ni títulos.

**Precondiciones:**
No existen registros para la fecha 2024-01-01.

**Pasos a seguir:**
1. El usuario ingresa la fecha '2024-01-01', recaudadora '1', caja 'A'.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra la tabla vacía o un mensaje indicando que no hay registros.

**Datos de prueba:**
{ "fecha": "2024-01-01", "rec": 1, "caja": "A" }

---

