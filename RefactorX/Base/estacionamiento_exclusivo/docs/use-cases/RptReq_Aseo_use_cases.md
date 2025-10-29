# Casos de Uso - RptReq_Aseo

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos de Aseo por Rango de Folios

**Descripción:** El usuario ingresa un rango de folios y una oficina recaudadora para obtener el reporte de adeudos de aseo contratado.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el rango de folios y el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página 'Orden de Requerimiento de Pago y Embargo (Aseo)'.
2. Ingresar el folio inicial (ej. 1000).
3. Ingresar el folio final (ej. 1010).
4. Ingresar el ID de la recaudadora (ej. 5).
5. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una lista de adeudos correspondientes al rango de folios y la recaudadora seleccionada, junto con los datos de la recaudadora.

**Datos de prueba:**
{ "folio1": 1000, "folio2": 1010, "ofna": 5 }

---

## Caso de Uso 2: Consulta sin Resultados

**Descripción:** El usuario consulta un rango de folios para los cuales no existen adeudos registrados.

**Precondiciones:**
El usuario tiene acceso al sistema y el rango de folios no tiene registros.

**Pasos a seguir:**
1. Acceder a la página del reporte.
2. Ingresar un folio inicial y final fuera del rango existente (ej. 999999 a 1000000).
3. Ingresar un ID de recaudadora válido.
4. Presionar 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron registros para los parámetros indicados.

**Datos de prueba:**
{ "folio1": 999999, "folio2": 1000000, "ofna": 5 }

---

## Caso de Uso 3: Validación de Parámetros Faltantes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página del reporte.
2. Dejar vacío el campo 'Folio Inicial'.
3. Ingresar los demás campos.
4. Presionar 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros requeridos.

**Datos de prueba:**
{ "folio1": null, "folio2": 1010, "ofna": 5 }

---

