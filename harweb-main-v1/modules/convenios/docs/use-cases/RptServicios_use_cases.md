# Casos de Uso - RptServicios

**Categoría:** Form

## Caso de Uso 1: Consulta del Catálogo Completo de Servicios

**Descripción:** El usuario accede a la página de catálogo de servicios y visualiza la lista completa de servicios/obra pública.

**Precondiciones:**
El usuario tiene acceso a la aplicación web y permisos para consultar el catálogo.

**Pasos a seguir:**
1. El usuario navega a la ruta '/rpt-servicios'.
2. El frontend realiza una petición POST a '/api/execute' con eRequest='RptServicios.getAll'.
3. El backend ejecuta el stored procedure 'rptservicios_get_all' y devuelve los datos.
4. El frontend muestra la tabla con los servicios y el total.

**Resultado esperado:**
El usuario visualiza una tabla con todos los servicios y el total de registros al pie.

**Datos de prueba:**
Base de datos con al menos 5 registros en ta_17_servicios.

---

## Caso de Uso 2: Visualización del Total de Servicios

**Descripción:** El usuario visualiza el total de servicios registrados en el catálogo.

**Precondiciones:**
El usuario está en la página de catálogo de servicios.

**Pasos a seguir:**
1. El frontend realiza una petición POST a '/api/execute' con eRequest='RptServicios.count'.
2. El backend ejecuta el stored procedure 'rptservicios_count' y devuelve el número total.
3. El frontend muestra el total en la sección correspondiente.

**Resultado esperado:**
El total de servicios se muestra correctamente y coincide con el número de filas en la tabla.

**Datos de prueba:**
Base de datos con 10 registros en ta_17_servicios.

---

## Caso de Uso 3: Manejo de Error en la Consulta

**Descripción:** El sistema maneja correctamente un error de base de datos (por ejemplo, si la tabla no existe).

**Precondiciones:**
La tabla ta_17_servicios ha sido renombrada o eliminada temporalmente.

**Pasos a seguir:**
1. El usuario accede a la página '/rpt-servicios'.
2. El frontend realiza la petición a '/api/execute'.
3. El backend intenta ejecutar el stored procedure y falla.
4. El backend devuelve un error en el campo 'error'.
5. El frontend muestra un mensaje de error al usuario.

**Resultado esperado:**
El usuario ve un mensaje de error claro y la página no se bloquea.

**Datos de prueba:**
No existe la tabla ta_17_servicios en la base de datos.

---

