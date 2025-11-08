# Casos de Uso - RptTitulos

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de títulos por fecha y folio válidos

**Descripción:** El usuario ingresa una fecha y un folio existentes y obtiene el reporte correspondiente.

**Precondiciones:**
Existen registros en las tablas ta_13_titulos, ta_13_datosrcm y tc_13_cementerios para la fecha y folio dados.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Títulos.
2. Ingresa la fecha '2024-06-01' y folio '12345'.
3. Presiona el botón 'Buscar'.
4. El sistema consulta el backend y muestra los resultados en la tabla.

**Resultado esperado:**
Se muestra una tabla con los datos del reporte de títulos para la fecha y folio ingresados.

**Datos de prueba:**
{ "fecha": "2024-06-01", "folio": 12345 }

---

## Caso de Uso 2: Consulta sin resultados

**Descripción:** El usuario ingresa una fecha y folio para los cuales no existen registros.

**Precondiciones:**
No existen registros para la fecha '2024-01-01' y folio '99999'.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Títulos.
2. Ingresa la fecha '2024-01-01' y folio '99999'.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay resultados para los criterios seleccionados.

**Datos de prueba:**
{ "fecha": "2024-01-01", "folio": 99999 }

---

## Caso de Uso 3: Error por parámetros faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar la fecha o el folio.

**Precondiciones:**
El usuario deja vacío el campo de fecha o folio.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Títulos.
2. Deja vacío el campo de fecha o folio.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que los parámetros son requeridos.

**Datos de prueba:**
{ "fecha": "", "folio": "" }

---

