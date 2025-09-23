# Casos de Uso - RptFact_Merc

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de facturación para un rango de folios válido

**Descripción:** El usuario ingresa una zona y un rango de folios existentes y obtiene el reporte correspondiente.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la base de datos para la zona y folios indicados.

**Pasos a seguir:**
1. Acceder a la página de Facturación de Requerimientos de Mercados.
2. Ingresar el número de zona (por ejemplo, 5).
3. Ingresar el folio inicial (por ejemplo, 1000).
4. Ingresar el folio final (por ejemplo, 1010).
5. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los registros correspondientes al rango de folios y zona ingresados.

**Datos de prueba:**
{ "rec": 5, "fol1": 1000, "fol2": 1010 }

---

## Caso de Uso 2: Consulta sin resultados (rango de folios inexistente)

**Descripción:** El usuario ingresa una zona y un rango de folios para los cuales no existen registros.

**Precondiciones:**
El usuario tiene acceso a la aplicación y el rango de folios no existe en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de Facturación de Requerimientos de Mercados.
2. Ingresar el número de zona (por ejemplo, 99).
3. Ingresar el folio inicial (por ejemplo, 99999).
4. Ingresar el folio final (por ejemplo, 100000).
5. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje indicando que no se encontraron resultados para los parámetros ingresados.

**Datos de prueba:**
{ "rec": 99, "fol1": 99999, "fol2": 100000 }

---

## Caso de Uso 3: Error por parámetros insuficientes

**Descripción:** El usuario intenta consultar el reporte sin ingresar todos los parámetros requeridos.

**Precondiciones:**
El usuario tiene acceso a la aplicación.

**Pasos a seguir:**
1. Acceder a la página de Facturación de Requerimientos de Mercados.
2. Dejar vacío el campo de zona o alguno de los folios.
3. Presionar el botón 'Consultar'.

**Resultado esperado:**
Se muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
{ "rec": null, "fol1": 1000, "fol2": 1010 }

---

