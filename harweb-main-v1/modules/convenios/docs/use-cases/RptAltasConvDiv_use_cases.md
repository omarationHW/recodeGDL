# Casos de Uso - RptAltasConvDiv

**Categoría:** Form

## Caso de Uso 1: Consulta de Altas de Convenios Diversos por Zona Centro

**Descripción:** El usuario desea obtener el listado de convenios dados de alta en la Zona Centro entre dos fechas.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Accede a la página de Altas de Convenios Diversos.
2. Selecciona 'Zona Centro' en el campo Recaudadora.
3. Ingresa la fecha inicial y final del rango deseado.
4. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los convenios dados de alta en la Zona Centro en el rango de fechas seleccionado, incluyendo expediente, nombre, domicilio, fecha alta, adeudo, vigencia, tipo y subtipo.

**Datos de prueba:**
{ "rec": "ZC1", "fecha1": "2024-01-01", "fecha2": "2024-06-30" }

---

## Caso de Uso 2: Exportación de Reporte de Altas a Excel

**Descripción:** El usuario requiere exportar el reporte de altas de convenios diversos a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta exitosa del reporte.

**Pasos a seguir:**
1. Después de ver el reporte en pantalla, presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se descarga un archivo Excel con el contenido del reporte mostrado.

**Datos de prueba:**
{ "rec": "ZO3", "fecha1": "2024-05-01", "fecha2": "2024-05-31" }

---

## Caso de Uso 3: Validación de Parámetros Insuficientes

**Descripción:** El usuario intenta consultar el reporte sin seleccionar recaudadora o fechas.

**Precondiciones:**
El usuario accede a la página pero deja campos requeridos vacíos.

**Pasos a seguir:**
1. Deja vacío el campo de recaudadora o fechas.
2. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
{ "rec": "", "fecha1": "", "fecha2": "" }

---

