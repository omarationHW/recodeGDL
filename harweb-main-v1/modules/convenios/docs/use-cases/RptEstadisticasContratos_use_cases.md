# Casos de Uso - RptEstadisticasContratos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadísticas de Pagos por Año y Fondo

**Descripción:** El usuario desea consultar el resumen de pagos de contratos para un año y fondo específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. Accede a la página de Estadísticas de Contratos.
2. Selecciona el año de obra (ej. 2023).
3. Selecciona el fondo/programa (ej. Ramo 33).
4. Presiona el botón 'Consultar'.
5. El sistema muestra la tabla de estadísticas.

**Resultado esperado:**
Se muestra una tabla con los totales de convenios, pagos, saldos y porcentajes por colonia.

**Datos de prueba:**
Año: 2023, Fondo: 16 (Ramo 33)

---

## Caso de Uso 2: Exportación de Reporte de Estadísticas

**Descripción:** El usuario desea exportar el reporte de estadísticas a Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. Presiona el botón 'Exportar'.
2. El sistema genera el archivo y lo descarga o muestra un enlace de descarga.

**Resultado esperado:**
El usuario obtiene un archivo Excel/CSV con los datos del reporte.

**Datos de prueba:**
Año: 2022, Fondo: 15 (Obra Directa)

---

## Caso de Uso 3: Consulta sin Resultados

**Descripción:** El usuario consulta un año/fondo sin datos registrados.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Selecciona un año y fondo sin datos (ej. año 1990, fondo 99).
2. Presiona 'Consultar'.

**Resultado esperado:**
El sistema muestra la tabla vacía y un mensaje indicando que no hay datos.

**Datos de prueba:**
Año: 1990, Fondo: 99

---

