# Casos de Uso - RptRecup_Merc

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de requerimiento de pago y embargo por rango de folios

**Descripción:** El usuario ingresa la zona/oficina y un rango de folios para obtener el reporte de adeudos de mercados.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los valores de zona/oficina y rango de folios válidos.

**Pasos a seguir:**
1. Ingresar el número de zona/oficina (ofna).
2. Ingresar el folio inicial (folio1).
3. Ingresar el folio final (folio2).
4. Presionar el botón 'Consultar'.
5. El sistema muestra la tabla con los resultados del reporte.

**Resultado esperado:**
Se muestra una tabla con los adeudos de mercados correspondientes al rango de folios y zona seleccionados, incluyendo totales y detalles por local.

**Datos de prueba:**
{ "ofna": 2, "folio1": 100, "folio2": 105 }

---

## Caso de Uso 2: Consulta de datos de recaudadora para cabecera de reporte

**Descripción:** El sistema obtiene los datos de la recaudadora y zona para mostrar en la cabecera del reporte.

**Precondiciones:**
Existe una recaudadora con el id proporcionado.

**Pasos a seguir:**
1. El frontend solicita los datos de la recaudadora usando el id (reca).
2. El backend ejecuta el stored procedure correspondiente.
3. El sistema retorna los datos de la recaudadora y zona.

**Resultado esperado:**
Se obtienen los datos de la recaudadora (nombre, domicilio, zona, etc.) para mostrar en la cabecera del reporte.

**Datos de prueba:**
{ "reca": 2 }

---

## Caso de Uso 3: Conversión de fecha a letras para impresión de reporte

**Descripción:** El sistema convierte una fecha de corte a formato de letras para mostrar en el reporte impreso.

**Precondiciones:**
El usuario tiene una fecha válida (YYYY-MM-DD).

**Pasos a seguir:**
1. El frontend solicita la conversión de la fecha usando el endpoint con el parámetro fecha.
2. El backend ejecuta el stored procedure fecha_aletras.
3. El sistema retorna la fecha en formato de letras.

**Resultado esperado:**
La fecha se muestra en formato '5 de Junio de 2024'.

**Datos de prueba:**
{ "fecha": "2024-06-05" }

---

