# Casos de Uso - RepDescImpto

**Categoría:** Form

## Caso de Uso 1: Consulta de descuentos aplicados por fecha de alta

**Descripción:** El usuario desea obtener un listado de todos los descuentos de impuesto predial aplicados entre dos fechas de alta, filtrando por una recaudadora específica.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de Reporte de Descuentos de Impuesto Predial.
2. Selecciona 'Aplicados' como tipo de archivo.
3. Selecciona 'Fecha Alta' como filtro de fecha.
4. Ingresa la fecha inicial y final.
5. Selecciona una recaudadora específica del catálogo.
6. Da clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los descuentos aplicados en el rango de fechas y recaudadora seleccionada.

**Datos de prueba:**
{ "tipoArchivo": "aplicados", "tipoFecha": 1, "fecha1": "2024-01-01", "fecha2": "2024-03-31", "recaudadora": 2, "tipoDescuento": "" }

---

## Caso de Uso 2: Consulta de descuentos reactivados por tipo de descuento

**Descripción:** El usuario requiere ver los descuentos reactivados de un tipo específico, sin filtrar por fechas ni recaudadora.

**Precondiciones:**
El usuario tiene acceso y permisos.

**Pasos a seguir:**
1. Accede a la página del reporte.
2. Selecciona 'Reactivados' como tipo de archivo.
3. Deja los filtros de fecha y recaudadora en 'Todos'.
4. Selecciona un tipo de descuento específico.
5. Da clic en 'Buscar'.

**Resultado esperado:**
Se listan todos los descuentos reactivados del tipo seleccionado.

**Datos de prueba:**
{ "tipoArchivo": "reactivados", "tipoFecha": 0, "fecha1": "", "fecha2": "", "recaudadora": "", "tipoDescuento": 5 }

---

## Caso de Uso 3: Exportación de resultados a Excel

**Descripción:** El usuario desea exportar el listado de descuentos aplicados a Excel para análisis externo.

**Precondiciones:**
El usuario ya realizó una búsqueda y tiene resultados en pantalla.

**Pasos a seguir:**
1. Realiza una búsqueda de descuentos aplicados.
2. Da clic en 'Exportar Excel'.

**Resultado esperado:**
El navegador descarga o imprime la tabla de resultados en formato Excel o similar.

**Datos de prueba:**
No aplica (acción sobre resultados ya cargados).

---

