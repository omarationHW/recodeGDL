# Casos de Uso - RptRecup_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de adeudos de aseo por rango de folios

**Descripción:** El usuario desea obtener el reporte de adeudos de aseo contratado para un rango de folios y una oficina específica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los folios y la oficina.

**Pasos a seguir:**
1. Ingresar el folio inicial (ej: 1000).
2. Ingresar el folio final (ej: 1010).
3. Ingresar el ID de la oficina (ej: 5).
4. Presionar el botón 'Generar Reporte'.
5. El sistema muestra la lista de adeudos y los datos de la recaudadora.

**Resultado esperado:**
Se muestra una lista de tarjetas con los datos de cada adeudo, totales y datos de la recaudadora.

**Datos de prueba:**
folio1: 1000, folio2: 1010, ofna: 5

---

## Caso de Uso 2: Validación de parámetros requeridos

**Descripción:** El usuario intenta generar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario accede a la página del reporte.

**Pasos a seguir:**
1. Dejar vacío el campo 'folio inicial'.
2. Ingresar el folio final y la oficina.
3. Presionar 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros requeridos.

**Datos de prueba:**
folio1: '', folio2: 1010, ofna: 5

---

## Caso de Uso 3: Reporte sin resultados

**Descripción:** El usuario consulta un rango de folios para los cuales no existen adeudos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Ingresar un rango de folios inexistente (ej: 999999 a 999999).
2. Ingresar la oficina.
3. Presionar 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron registros.

**Datos de prueba:**
folio1: 999999, folio2: 999999, ofna: 5

---

