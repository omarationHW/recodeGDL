# Casos de Uso - pagosmultfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de pagos de multas por fecha y recaudadora

**Descripción:** El usuario desea consultar todos los pagos de multas realizados en una fecha específica y por una recaudadora determinada.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos de multas registrados para la fecha y recaudadora indicadas.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de multas.
2. Ingresa la fecha (por ejemplo, 2024-06-01) y el número de recaudadora (por ejemplo, 1).
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos de multas correspondientes a la fecha y recaudadora seleccionadas.

**Datos de prueba:**
{ "fecha": "2024-06-01", "recaud": "1" }

---

## Caso de Uso 2: Consulta de detalle de multa y descuentos

**Descripción:** El usuario consulta el detalle de una multa específica, incluyendo los descuentos aplicados.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene a la vista la lista de pagos de multas.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Detalle' de un pago de la lista.
2. El sistema consulta y muestra el detalle de la multa, incluyendo información de contribuyente, domicilio, giro, calificación, descuento, multa, gastos, total, estatus y observaciones.
3. El sistema muestra una tabla con los descuentos aplicados a la multa.

**Resultado esperado:**
Se muestra el detalle completo de la multa y los descuentos asociados.

**Datos de prueba:**
{ "id_multa": 1001 }

---

## Caso de Uso 3: Búsqueda por nombre de contribuyente y número de acta

**Descripción:** El usuario busca pagos de multas filtrando por nombre de contribuyente y número de acta.

**Precondiciones:**
Existen pagos de multas asociados al nombre y número de acta proporcionados.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de multas.
2. Ingresa el nombre del contribuyente (por ejemplo, 'JUAN') y el número de acta (por ejemplo, 456).
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos de multas que coinciden con el nombre y número de acta indicados.

**Datos de prueba:**
{ "nombre": "JUAN", "num_acta": "456" }

---

