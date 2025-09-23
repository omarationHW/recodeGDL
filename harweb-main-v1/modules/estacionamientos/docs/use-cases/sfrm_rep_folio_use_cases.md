# Casos de Uso - sfrm_rep_folio

**Categoría:** Form

## Caso de Uso 1: Reporte de Folios Elaborados por Todos los Vigilantes en una Fecha

**Descripción:** El usuario desea obtener un reporte de todos los folios elaborados en una fecha específica, sin filtrar por vigilante.

**Precondiciones:**
Existen registros en las tablas ta14_folios_adeudo, ta14_folios_histo, ta14_personas, ta14_tarifas para la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Reportes de Folios.
2. Selecciona 'Reporte de los folios elaborados'.
3. No marca el checkbox 'Todos vigilantes / uno solo'.
4. Selecciona la fecha deseada.
5. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con todos los folios elaborados en la fecha seleccionada, agrupados por vigilante e inspector.

**Datos de prueba:**
{ "eRequest": "getFoliosReport", "params": { "date": "2024-06-15", "vigila": null, "mode": "elaborados" } }

---

## Caso de Uso 2: Reporte de Folios Capturados por un Vigilante Específico

**Descripción:** El usuario desea obtener un reporte de los folios capturados en una fecha específica por un vigilante determinado.

**Precondiciones:**
Existen registros para la fecha y el vigilante seleccionado.

**Pasos a seguir:**
1. El usuario accede a la página de Reportes de Folios.
2. Selecciona 'Reporte de los folios capturados'.
3. Marca el checkbox 'Todos vigilantes / uno solo'.
4. Selecciona el vigilante deseado de la lista.
5. Selecciona la fecha.
6. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con los folios capturados por el vigilante seleccionado en la fecha indicada.

**Datos de prueba:**
{ "eRequest": "getFoliosReport", "params": { "date": "2024-06-15", "vigila": 5, "mode": "capturados" } }

---

## Caso de Uso 3: Conteo de Folios Hechos por Inspector en una Fecha

**Descripción:** El usuario desea ver cuántos folios hizo cada inspector en una fecha dada.

**Precondiciones:**
Existen folios elaborados en la fecha seleccionada.

**Pasos a seguir:**
1. El usuario accede a la página de Reportes de Folios.
2. Selecciona 'Reporte de folios hechos por vigilante'.
3. Selecciona la fecha.
4. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con la lista de inspectores y el número de folios hechos por cada uno en la fecha.

**Datos de prueba:**
{ "eRequest": "getFoliosByInspector", "params": { "date": "2024-06-15" } }

---

