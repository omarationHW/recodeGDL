# Casos de Uso - sfrm_reportescalco

**Categoría:** Form

## Caso de Uso 1: Generar reporte de calcomanías expedidas en un periodo

**Descripción:** El usuario desea obtener un listado de todas las calcomanías expedidas entre dos fechas específicas.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros de calcomanías en el periodo seleccionado.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Calcomanías.
2. Seleccionar la fecha inicial y final del periodo deseado.
3. Presionar el botón 'Imprimir Reporte de Calcomanías Expedidas'.

**Resultado esperado:**
Se muestra una tabla con todas las calcomanías expedidas en el periodo, incluyendo placa, número de calco, fechas, propietario, vigencia, operación de caja e importe pagado.

**Datos de prueba:**
fecha1: '2024-01-01', fecha2: '2024-01-31'

---

## Caso de Uso 2: Generar reporte de folios capturados por inspector en un día

**Descripción:** El usuario requiere saber cuántos folios fueron capturados por cada inspector en una fecha específica.

**Precondiciones:**
Existen folios capturados en la fecha seleccionada.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Calcomanías.
2. Seleccionar la fecha deseada en el campo 'Periodo de la relación'.
3. Presionar el botón 'Imprimir Reporte de Folios Capturados'.

**Resultado esperado:**
Se muestra una tabla con el nombre de cada inspector y la cantidad de folios capturados ese día.

**Datos de prueba:**
fechora: '2024-02-15'

---

## Caso de Uso 3: Validar manejo de errores al ingresar fechas sin registros

**Descripción:** El usuario selecciona un rango de fechas donde no existen registros de calcomanías o folios.

**Precondiciones:**
No existen registros en la base de datos para el rango de fechas seleccionado.

**Pasos a seguir:**
1. Ingresar a la página de Reportes de Calcomanías.
2. Seleccionar un rango de fechas sin registros.
3. Presionar cualquiera de los botones de reporte.

**Resultado esperado:**
El sistema muestra una tabla vacía o un mensaje indicando que no se encontraron resultados.

**Datos de prueba:**
fecha1: '1990-01-01', fecha2: '1990-01-02'

---

