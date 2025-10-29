# Casos de Uso - RptIngresoZonificado

**Categoría:** Form

## Caso de Uso 1: Consulta de Ingreso Zonificado por Fechas

**Descripción:** El usuario desea obtener el total de ingresos por zona entre el 1 y el 31 de enero de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Ingreso Zonificado.
2. Selecciona fecha desde '2024-01-01' y fecha hasta '2024-01-31'.
3. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con las zonas y el total de ingresos por zona en el periodo, y el total global.

**Datos de prueba:**
{ "fecdesde": "2024-01-01", "fechasta": "2024-01-31" }

---

## Caso de Uso 2: Exportar Reporte de Ingreso Zonificado a PDF

**Descripción:** El usuario desea exportar el reporte consultado a PDF.

**Precondiciones:**
El usuario ya realizó una consulta exitosa.

**Pasos a seguir:**
1. Presiona el botón 'Exportar PDF'.

**Resultado esperado:**
Se descarga o abre el PDF con el reporte de ingresos por zona.

**Datos de prueba:**
{ "fecdesde": "2024-01-01", "fechasta": "2024-01-31" }

---

## Caso de Uso 3: Validación de Fechas Inválidas

**Descripción:** El usuario intenta consultar el reporte sin seleccionar fechas.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página de Ingreso Zonificado.
2. Deja los campos de fecha vacíos.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que las fechas son requeridas.

**Datos de prueba:**
{ "fecdesde": "", "fechasta": "" }

---

