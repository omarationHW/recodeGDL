# Casos de Uso - RptReq_Merc

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de requerimiento de pago para un rango de folios

**Descripción:** El usuario ingresa la oficina (zona) y un rango de folios para obtener el reporte de requerimiento de pago y embargo de mercados.

**Precondiciones:**
El usuario debe estar autenticado y tener permisos para consultar reportes.

**Pasos a seguir:**
1. Ingresar el número de oficina (zona).
2. Ingresar el folio inicial y final.
3. Presionar el botón 'Consultar'.
4. El sistema muestra los resultados en tarjetas con la información detallada.

**Resultado esperado:**
Se muestran todos los registros del reporte para el rango de folios y oficina seleccionados, con totales y detalles correctos.

**Datos de prueba:**
{ "ofna": 1, "folio1": 100, "folio2": 105 }

---

## Caso de Uso 2: Consulta de información de recaudadora

**Descripción:** El usuario requiere ver los datos de la recaudadora y zona asociada para una oficina específica.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. Ingresar el número de recaudadora.
2. Enviar la petición con acción 'getRecaudadoraInfo'.
3. El sistema retorna los datos de la recaudadora y zona.

**Resultado esperado:**
Se muestran los datos de la recaudadora, domicilio, teléfono, recaudador y zona.

**Datos de prueba:**
{ "reca": 1 }

---

## Caso de Uso 3: Validación de error por rango de folios inválido

**Descripción:** El usuario ingresa un rango de folios donde el folio inicial es mayor que el final.

**Precondiciones:**
El usuario debe estar autenticado.

**Pasos a seguir:**
1. Ingresar el número de oficina (zona).
2. Ingresar folio inicial mayor que el folio final.
3. Presionar 'Consultar'.
4. El sistema valida y muestra un mensaje de error.

**Resultado esperado:**
El sistema retorna un error indicando que el rango de folios es inválido.

**Datos de prueba:**
{ "ofna": 1, "folio1": 200, "folio2": 100 }

---

