# Casos de Uso - RptPagosContratosDecsDev

**Categoría:** Form

## Caso de Uso 1: Consulta de contratos con descuento para una colonia existente

**Descripción:** El usuario desea obtener el listado de contratos que han pagado con descuento en una colonia específica.

**Precondiciones:**
La colonia existe en la base de datos y tiene contratos con pagos con descuento.

**Pasos a seguir:**
1. El usuario accede a la página del reporte.
2. Ingresa el número de colonia (por ejemplo, 5) en el formulario.
3. Presiona el botón 'Buscar'.
4. El sistema consulta la API y muestra el listado de contratos con los campos requeridos.

**Resultado esperado:**
Se muestra una tabla con los contratos, incluyendo totales y datos de la colonia.

**Datos de prueba:**
{ "colonia": 5 }

---

## Caso de Uso 2: Consulta para colonia sin contratos con descuento

**Descripción:** El usuario consulta una colonia que existe pero no tiene contratos con pagos con descuento.

**Precondiciones:**
La colonia existe pero no hay registros de pagos con descuento.

**Pasos a seguir:**
1. El usuario accede a la página del reporte.
2. Ingresa el número de colonia (por ejemplo, 99) en el formulario.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de 'No hay datos para mostrar.'

**Datos de prueba:**
{ "colonia": 99 }

---

## Caso de Uso 3: Consulta con parámetro de colonia inválido

**Descripción:** El usuario intenta consultar el reporte sin ingresar un número de colonia válido.

**Precondiciones:**
El usuario no ingresa ningún valor o ingresa un valor no numérico.

**Pasos a seguir:**
1. El usuario accede a la página del reporte.
2. Deja el campo colonia vacío o ingresa un texto no numérico.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que el parámetro colonia es requerido.

**Datos de prueba:**
{ "colonia": "" }

---

