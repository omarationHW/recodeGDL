# Casos de Uso - repEstadisticosLicfrm

**Categoría:** Form

## Caso de Uso 1: Reporte de licencias dadas de alta en un rango de fechas

**Descripción:** El usuario desea obtener un reporte de todas las licencias dadas de alta entre dos fechas específicas, agrupadas por giro y zona.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de reportes estadísticos de licencias.
2. Selecciona la opción 'Licencias dadas de alta en un rango de tiempo'.
3. Ingresa la fecha inicial y final.
4. Presiona el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los giros, descripción y el conteo de licencias por zona (z_1 a z_7, otros, total) en el rango de fechas seleccionado.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-06-30" }

---

## Caso de Uso 2: Reporte de giros reglamentados por zona (solo tipo C)

**Descripción:** El usuario requiere un reporte de los giros reglamentados tipo C agrupados por zona.

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Accede a la página de reportes estadísticos.
2. Selecciona 'Giros reglamentados por zona'.
3. Selecciona 'Solo C' en clasificación.
4. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los giros tipo C y el conteo por zona.

**Datos de prueba:**
{ "clasificacion": "C" }

---

## Caso de Uso 3: Reporte de pagos de licencias en un rango de fechas

**Descripción:** El usuario desea saber cuántos pagos de licencias se han realizado en cada recaudadora en un periodo.

**Precondiciones:**
El usuario tiene acceso y existen pagos registrados.

**Pasos a seguir:**
1. Accede a la página de reportes.
2. Selecciona 'Pagos de licencias en un rango de tiempo'.
3. Ingresa la fecha inicial y final.
4. Presiona 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con el número de pagos por recaudadora.

**Datos de prueba:**
{ "fecha1": "2024-01-01", "fecha2": "2024-06-30" }

---

