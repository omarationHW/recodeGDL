# Casos de Uso - RptPrenomina

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de prenómina para todas las zonas

**Descripción:** El usuario desea obtener el reporte de pagos a ejecutores para todas las zonas en un periodo determinado.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en las tablas correspondientes.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte Prenómina.
2. Selecciona la fecha de inicio y fin del periodo.
3. Selecciona recaudadora inicial = 1 y recaudadora final = 9 (todas).
4. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra la tabla con los pagos a ejecutores de todas las zonas en el periodo seleccionado, junto con los totales generales y por tipo.

**Datos de prueba:**
{
  "fec1": "2024-01-01",
  "fec2": "2024-01-31",
  "recaud": 1,
  "recaud1": 9
}

---

## Caso de Uso 2: Consulta de reporte de prenómina para una recaudadora específica

**Descripción:** El usuario desea obtener el reporte de pagos a ejecutores para la recaudadora 3 únicamente.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos para la recaudadora 3.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte Prenómina.
2. Selecciona la fecha de inicio y fin del periodo.
3. Selecciona recaudadora inicial = 3 y recaudadora final = 3.
4. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra la tabla con los pagos a ejecutores de la recaudadora 3 en el periodo seleccionado, junto con los totales.

**Datos de prueba:**
{
  "fec1": "2024-02-01",
  "fec2": "2024-02-28",
  "recaud": 3,
  "recaud1": 3
}

---

## Caso de Uso 3: Validación de parámetros insuficientes

**Descripción:** El usuario intenta generar el reporte sin seleccionar todas las fechas o recaudadoras.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte Prenómina.
2. Deja vacío uno de los campos requeridos (por ejemplo, fecha fin).
3. Hace clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
{
  "fec1": "2024-03-01",
  "fec2": "",
  "recaud": 1,
  "recaud1": 9
}

---

