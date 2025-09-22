# Casos de Uso - RptCalles

**Categoría:** Form

## Caso de Uso 1: Consulta de catálogo de calles para un año vigente

**Descripción:** El usuario desea consultar el catálogo de colonias y calles para el año de obra 2023.

**Precondiciones:**
Existen registros en las tablas ta_17_calles, ta_17_servicios, ta_17_colonias y ta_17_tipos para el año 2023.

**Pasos a seguir:**
1. El usuario accede a la página 'Catálogo de Colonias para Obra'.
2. Ingresa '2023' en el campo 'Año de Obra'.
3. Presiona el botón 'Buscar'.
4. El sistema envía una petición POST a /api/execute con action 'RptCalles.getCallesByAxo' y data { axo: 2023 }.
5. El backend ejecuta el stored procedure y retorna los datos agrupados por colonia.
6. El frontend muestra la tabla con los resultados.

**Resultado esperado:**
Se muestra una lista de colonias, cada una con sus calles, servicios, tipo y estado ('VIGENTE' o 'CANCELADA') correspondientes al año 2023.

**Datos de prueba:**
ta_17_calles: registros con axo_obra=2023, vigencia_obra='A' y 'C'.

---

## Caso de Uso 2: Consulta sin resultados para año inexistente

**Descripción:** El usuario consulta un año para el cual no existen registros.

**Precondiciones:**
No existen registros en ta_17_calles para axo_obra=2099.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Ingresa '2099' en el campo 'Año de Obra'.
3. Presiona 'Buscar'.
4. El sistema consulta la API con axo=2099.
5. El backend retorna un arreglo vacío.

**Resultado esperado:**
El frontend muestra el mensaje 'No hay datos para el año seleccionado.'

**Datos de prueba:**
ta_17_calles: sin registros para axo_obra=2099.

---

## Caso de Uso 3: Error por parámetro faltante

**Descripción:** El usuario intenta consultar sin ingresar el año de obra.

**Precondiciones:**
El usuario deja el campo 'Año de Obra' vacío.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Deja vacío el campo 'Año de Obra'.
3. Presiona 'Buscar'.
4. El frontend valida y muestra error, o la API responde con error de parámetro.

**Resultado esperado:**
Se muestra un mensaje de error indicando que el parámetro axo es requerido.

**Datos de prueba:**
N/A

---

