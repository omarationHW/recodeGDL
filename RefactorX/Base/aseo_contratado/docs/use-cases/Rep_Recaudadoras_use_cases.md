# Casos de Uso - Rep_Recaudadoras

**Categoría:** Form

## Caso de Uso 1: Visualizar reporte de recaudadoras ordenado por nombre

**Descripción:** El usuario desea obtener un listado de todas las recaudadoras, ordenadas alfabéticamente por el nombre de la recaudadora.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página de 'Impresiones de Recaudadoras'.
2. Selecciona 'Nombre' como criterio de orden.
3. Hace clic en 'Vista Previa'.
4. El sistema consulta el backend y muestra la tabla ordenada por nombre.

**Resultado esperado:**
Se muestra una tabla con todas las recaudadoras, ordenadas alfabéticamente por el campo 'recaudadora'.

**Datos de prueba:**
Base de datos con al menos 3 recaudadoras con nombres distintos.

---

## Caso de Uso 2: Visualizar reporte de recaudadoras ordenado por sector

**Descripción:** El usuario requiere ver el listado de recaudadoras agrupadas por sector.

**Precondiciones:**
El usuario está autenticado y la tabla ta_12_recaudadoras tiene datos con diferentes sectores.

**Pasos a seguir:**
1. El usuario ingresa a la página de reporte de recaudadoras.
2. Selecciona 'Sector' como criterio de orden.
3. Presiona 'Vista Previa'.
4. El sistema retorna la lista ordenada por sector y luego por id_rec.

**Resultado esperado:**
La tabla muestra las recaudadoras agrupadas por sector, y dentro de cada sector ordenadas por id_rec.

**Datos de prueba:**
Recaudadoras con sectores 'Norte', 'Sur', 'Centro'.

---

## Caso de Uso 3: Manejo de error al fallar la consulta

**Descripción:** El usuario intenta consultar el reporte pero ocurre un error en la base de datos.

**Precondiciones:**
El backend tiene un problema de conexión o el stored procedure no existe.

**Pasos a seguir:**
1. El usuario accede a la página y selecciona cualquier criterio de orden.
2. Hace clic en 'Vista Previa'.
3. El backend lanza una excepción.

**Resultado esperado:**
El frontend muestra un mensaje de error informando que no se pudo obtener el reporte.

**Datos de prueba:**
Simular caída de la base de datos o renombrar temporalmente el stored procedure.

---

