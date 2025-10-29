# Casos de Uso - RptPagosDesarrollo

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de pagos de desarrollo para todo el año

**Descripción:** El usuario desea obtener el reporte de ingresos por fondo y año de obra pública para todo el año 2023.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Accede a la página 'Reporte de Pagos de Desarrollo'.
2. Selecciona '2023-01-01' como fecha desde y '2023-12-31' como fecha hasta.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los fondos, años de obra y el ingreso total por cada combinación, así como el total general.

**Datos de prueba:**
{ "fecdesde": "2023-01-01", "fechasta": "2023-12-31" }

---

## Caso de Uso 2: Validación de fechas requeridas

**Descripción:** El usuario intenta consultar el reporte sin seleccionar una de las fechas.

**Precondiciones:**
El usuario está en la página del reporte.

**Pasos a seguir:**
1. Deja vacío el campo 'Fecha Desde' o 'Fecha Hasta'.
2. Presiona 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que ambos campos son requeridos.

**Datos de prueba:**
{ "fecdesde": "", "fechasta": "2023-12-31" }

---

## Caso de Uso 3: Reporte sin resultados

**Descripción:** El usuario consulta un rango de fechas donde no existen pagos registrados.

**Precondiciones:**
No hay pagos en el rango '2025-01-01' a '2025-01-31'.

**Pasos a seguir:**
1. Selecciona '2025-01-01' como fecha desde y '2025-01-31' como fecha hasta.
2. Presiona 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no hay datos para el rango seleccionado.

**Datos de prueba:**
{ "fecdesde": "2025-01-01", "fechasta": "2025-01-31" }

---

