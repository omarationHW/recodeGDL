# Casos de Uso - RptPagosContabilidad

**Categoría:** Form

## Caso de Uso 1: Consulta de Reporte de Pagos Contabilidad por Rango de Fechas

**Descripción:** El usuario desea obtener el reporte de pagos de contabilidad para un rango de fechas específico.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en el rango de fechas.

**Pasos a seguir:**
1. El usuario accede a la página 'Reporte de Pagos Contabilidad'.
2. Selecciona la fecha de inicio y fin del reporte.
3. Presiona el botón 'Consultar'.
4. El sistema envía la petición al endpoint /api/execute con la acción 'getRptPagosContabilidad'.
5. El backend ejecuta el stored procedure y retorna los resultados.
6. El frontend muestra la tabla con los resultados y el total general.

**Resultado esperado:**
Se muestra una tabla con los pagos agrupados por fondo, año de obra y cuenta, incluyendo la descripción y el total general.

**Datos de prueba:**
{ "fecdesde": "2024-01-01", "fechasta": "2024-06-30" }

---

## Caso de Uso 2: Validación de Fechas Inválidas

**Descripción:** El usuario intenta consultar el reporte con una fecha final anterior a la fecha inicial.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El usuario accede a la página del reporte.
2. Selecciona una fecha de inicio mayor que la fecha de fin.
3. Presiona 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que las fechas son inválidas y no realiza la consulta.

**Datos de prueba:**
{ "fecdesde": "2024-07-01", "fechasta": "2024-06-30" }

---

## Caso de Uso 3: Consulta de Catálogo de Tipos de Fondo

**Descripción:** El frontend necesita mostrar el catálogo de tipos de fondo para filtros o descripciones.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. El frontend envía una petición a /api/execute con acción 'getTipos'.
2. El backend ejecuta el stored procedure sp_catalog_tipos.
3. El frontend recibe y muestra el catálogo.

**Resultado esperado:**
El frontend recibe un arreglo con los tipos y descripciones de fondo.

**Datos de prueba:**
{}

---

