# Casos de Uso - RptColonias

**Categoría:** Form

## Caso de Uso 1: Visualización del Catálogo de Colonias

**Descripción:** El usuario accede a la página de reporte de colonias y visualiza la lista completa de colonias con sus zonas.

**Precondiciones:**
El usuario tiene acceso a la aplicación web y permisos para consultar el catálogo.

**Pasos a seguir:**
1. El usuario navega a la ruta '/colonias' en la aplicación.
2. El componente Vue realiza una petición POST a '/api/execute' con eRequest='RptColoniasList'.
3. El backend ejecuta el stored procedure y retorna la lista de colonias.
4. El frontend muestra la tabla con los datos y el total de colonias.

**Resultado esperado:**
La tabla muestra todas las colonias, sus descripciones, zona y rec., y el total de colonias es correcto.

**Datos de prueba:**
Base de datos con al menos 3 colonias y 2 zonas diferentes.

---

## Caso de Uso 2: Manejo de Error de Base de Datos

**Descripción:** El sistema responde adecuadamente si ocurre un error en la consulta a la base de datos.

**Precondiciones:**
El stored procedure 'rpt_colonias_list' no existe o la conexión a la base de datos falla.

**Pasos a seguir:**
1. El usuario accede a la página de colonias.
2. El frontend envía la petición a '/api/execute'.
3. El backend intenta ejecutar el stored procedure y falla.
4. El backend retorna un eResponse='ERROR' y un mensaje de error.

**Resultado esperado:**
El usuario ve un mensaje de error amigable y la tabla no se muestra.

**Datos de prueba:**
Simular caída de la base de datos o renombrar temporalmente el stored procedure.

---

## Caso de Uso 3: Validación de eRequest no soportado

**Descripción:** El sistema rechaza peticiones con eRequest no implementados.

**Precondiciones:**
El usuario tiene acceso a la API.

**Pasos a seguir:**
1. El usuario (o un cliente API) envía una petición POST a '/api/execute' con eRequest='NoExiste'.
2. El backend procesa la petición y detecta que el eRequest no está soportado.

**Resultado esperado:**
La respuesta es un eResponse='ERROR' con mensaje 'eRequest not supported'.

**Datos de prueba:**
{ "eRequest": "NoExiste", "params": {} }

---

