# Casos de Uso - ExportarExcel

**Categoría:** Form

## Caso de Uso 1: Consulta y Exportación de Folios Pagos de Mercados

**Descripción:** El usuario consulta los folios pagos del módulo Mercados para una recaudadora específica y exporta los resultados a Excel.

**Precondiciones:**
El usuario está autenticado y tiene acceso al módulo ExportarExcel.

**Pasos a seguir:**
1. Accede a la página ExportarExcel.
2. Selecciona 'Mercados' como aplicación.
3. Selecciona la recaudadora 1.
4. Ingresa folio desde 100, folio hasta 200.
5. Selecciona fecha de emisión y rango de fechas de pago.
6. Presiona 'Consultar'.
7. Visualiza la tabla de resultados.
8. Presiona 'Exportar Excel'.

**Resultado esperado:**
Se muestran los folios pagos filtrados y se descarga un archivo Excel con los datos.

**Datos de prueba:**
{
  "prec": 1,
  "pmod": 11,
  "pfold": 100,
  "pfolh": 200,
  "pfemi": "2024-06-01",
  "pfpagd": "2024-06-01",
  "pfpagh": "2024-06-30"
}

---

## Caso de Uso 2: Consulta de Folios Pagos de Estacionamientos Públicos

**Descripción:** El usuario consulta los folios pagos del módulo Estacionamientos Públicos para un rango de folios y fechas.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página ExportarExcel.
2. Selecciona 'Estacionamientos Públicos' como aplicación.
3. Selecciona la recaudadora 2.
4. Ingresa folio desde 500, folio hasta 600.
5. Selecciona fecha de emisión y rango de fechas de pago.
6. Presiona 'Consultar'.

**Resultado esperado:**
Se muestran los folios pagos filtrados en la tabla.

**Datos de prueba:**
{
  "prec": 2,
  "pmod": 24,
  "pfold": 500,
  "pfolh": 600,
  "pfemi": "2024-06-01",
  "pfpagd": "2024-06-01",
  "pfpagh": "2024-06-30"
}

---

## Caso de Uso 3: Validación de Parámetros Obligatorios

**Descripción:** El usuario intenta consultar folios pagos sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. Accede a la página ExportarExcel.
2. Deja vacío el campo 'Folio Desde'.
3. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el campo es obligatorio.

**Datos de prueba:**
{
  "prec": 1,
  "pmod": 11,
  "pfold": null,
  "pfolh": 200,
  "pfemi": "2024-06-01",
  "pfpagd": "2024-06-01",
  "pfpagh": "2024-06-30"
}

---

