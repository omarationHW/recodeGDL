# Casos de Uso - spubreports

**Categoría:** Form

## Caso de Uso 1: Reporte por Categoría de Estacionamientos Públicos

**Descripción:** El usuario desea obtener un listado de todos los estacionamientos públicos ordenados por categoría.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen datos en las tablas pubmain y pubcategoria.

**Pasos a seguir:**
1. El usuario accede a la página de reportes.
2. Selecciona 'Por Categoría' en el selector de tipo de reporte.
3. Presiona el botón 'Generar Reporte'.
4. El frontend envía una petición POST a /api/execute con operation=spubreports_list y params={opc:1}.
5. El backend ejecuta el SP y retorna los datos.
6. El frontend muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una tabla con todos los estacionamientos públicos agrupados y ordenados por categoría.

**Datos de prueba:**
{ "opc": 1 }

---

## Caso de Uso 2: Resumen por Categoría y Sector

**Descripción:** El usuario requiere un resumen estadístico de estacionamientos por sector y categoría.

**Precondiciones:**
Existen datos en pubmain y pubcategoria.

**Pasos a seguir:**
1. El usuario accede a la página de reportes.
2. Selecciona 'Resumen por Categoría y Sector'.
3. Presiona 'Generar Reporte'.
4. El frontend envía operation=spubreports_sector_summary.
5. El backend ejecuta el SP y retorna los datos.
6. El frontend muestra la tabla resumen.

**Resultado esperado:**
Se muestra una tabla con las columnas de cantidad y capacidad por sector y totales.

**Datos de prueba:**
{}

---

## Caso de Uso 3: Relación de Adeudo y Pago

**Descripción:** El usuario desea ver la relación de adeudos y pagos de todos los estacionamientos.

**Precondiciones:**
Existen datos en pubmain, pubcategoria, pubadeudo y pubadeudo_histo.

**Pasos a seguir:**
1. El usuario accede a la página de reportes.
2. Selecciona 'Relación de Adeudo y Pago'.
3. Presiona 'Generar Reporte'.
4. El frontend envía operation=spubreports_adeudos.
5. El backend ejecuta el SP y retorna los datos.
6. El frontend muestra la tabla con los adeudos y pagos.

**Resultado esperado:**
Se muestra una tabla con los campos de adeudos anteriores, actuales, proyectados y últimos pagos.

**Datos de prueba:**
{}

---

