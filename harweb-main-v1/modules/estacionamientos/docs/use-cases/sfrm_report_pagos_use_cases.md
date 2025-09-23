# Casos de Uso - sfrm_report_pagos

**Categoría:** Form

## Caso de Uso 1: Generar reporte de folios pagados para una recaudadora y fecha específica

**Descripción:** El usuario desea obtener el listado de folios pagados en una recaudadora en una fecha determinada.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar reportes. Existen folios pagados en la fecha y recaudadora seleccionadas.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de folios pagados.
2. Selecciona 'Reporte de los folios pagados'.
3. Selecciona la fecha deseada (ej: 2024-06-15).
4. Hace clic en 'Generar Reporte'.
5. El sistema consulta el endpoint /api/execute con action=report_folios_pagados y los parámetros correspondientes.
6. El sistema muestra la tabla con los folios pagados y el total.

**Resultado esperado:**
Se muestra una tabla con los folios pagados en la recaudadora y fecha seleccionadas, incluyendo todos los campos relevantes y el total de folios.

**Datos de prueba:**
{ "reca": 1, "fechora": "2024-06-15" }

---

## Caso de Uso 2: Generar reporte de folios elaborados por el usuario actual

**Descripción:** El usuario desea ver todos los folios que él mismo elaboró en una fecha específica.

**Precondiciones:**
El usuario está autenticado y tiene folios elaborados en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de folios pagados.
2. Selecciona 'Folios Elaborados por el Usuario Actual'.
3. Selecciona la fecha deseada (ej: 2024-06-15).
4. Hace clic en 'Generar Reporte'.
5. El sistema consulta el endpoint /api/execute con action=report_folios_elaborados_usuario y los parámetros correspondientes.
6. El sistema muestra la tabla con los folios elaborados y los totales.

**Resultado esperado:**
Se muestra una tabla con los folios elaborados por el usuario en la fecha seleccionada, incluyendo totales de folios e importe.

**Datos de prueba:**
{ "fechora": "2024-06-15", "vigila": 1 }

---

## Caso de Uso 3: Obtener conteo de folios de adeudo por inspector en una fecha

**Descripción:** El usuario desea ver cuántos folios de adeudo tiene cada inspector en una fecha determinada.

**Precondiciones:**
Existen folios de adeudo registrados en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la funcionalidad de reporte de folios de adeudo por inspector (puede ser una extensión futura).
2. Selecciona la fecha deseada.
3. Hace clic en 'Generar Reporte'.
4. El sistema consulta el endpoint /api/execute con action=report_folios_adeudo_por_inspector y los parámetros correspondientes.
5. El sistema muestra la tabla con el conteo de folios por inspector.

**Resultado esperado:**
Se muestra una tabla con el nombre del inspector y la cantidad de folios de adeudo para la fecha seleccionada.

**Datos de prueba:**
{ "fechora": "2024-06-15" }

---

