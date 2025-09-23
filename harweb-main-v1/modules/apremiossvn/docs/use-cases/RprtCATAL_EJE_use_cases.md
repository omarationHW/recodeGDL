# Casos de Uso - RprtCATAL_EJE

**Categoría:** Form

## Caso de Uso 1: Consulta de ejecutores activos de una recaudadora

**Descripción:** El usuario desea obtener el listado de todos los ejecutores activos pertenecientes a la recaudadora con ID 1.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página 'Listado de Ejecutores'.
2. Ingresar '1' en el campo 'ID Recaudadora'.
3. Seleccionar 'Activos' en el filtro de vigencia.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los ejecutores activos de la recaudadora 1, incluyendo sus datos y el total de registros.

**Datos de prueba:**
{ "id_rec": 1, "vigencia": "A" }

---

## Caso de Uso 2: Consulta de todos los ejecutores (sin filtro de vigencia)

**Descripción:** El usuario desea ver todos los ejecutores (activos e inactivos) de la recaudadora 2.

**Precondiciones:**
El usuario tiene acceso y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página 'Listado de Ejecutores'.
2. Ingresar '2' en el campo 'ID Recaudadora'.
3. Seleccionar 'Todos' en el filtro de vigencia.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los ejecutores (activos e inactivos) de la recaudadora 2.

**Datos de prueba:**
{ "id_rec": 2, "vigencia": "" }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario busca ejecutores activos en una recaudadora inexistente (ID 999).

**Precondiciones:**
El usuario tiene acceso al sistema.

**Pasos a seguir:**
1. Acceder a la página 'Listado de Ejecutores'.
2. Ingresar '999' en el campo 'ID Recaudadora'.
3. Seleccionar 'Activos' en el filtro de vigencia.
4. Presionar el botón 'Buscar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron ejecutores para los filtros seleccionados.

**Datos de prueba:**
{ "id_rec": 999, "vigencia": "A" }

---

