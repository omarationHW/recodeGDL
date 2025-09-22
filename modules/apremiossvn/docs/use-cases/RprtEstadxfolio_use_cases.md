# Casos de Uso - RprtEstadxfolio

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de notificaciones por folio (caso normal)

**Descripción:** El usuario ingresa los parámetros de módulo, recaudadora y rango de folios, y obtiene el reporte agrupado.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos en el rango solicitado.

**Pasos a seguir:**
1. Acceder a la página 'Estadística de Notificaciones por Folio'.
2. Seleccionar 'Mercados' como módulo.
3. Ingresar recaudadora 1.
4. Ingresar folio inicial 1000 y folio final 2000.
5. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los resultados agrupados por vigencia y clave_practicado, mostrando sumatorias de folios, gastos, adeudo y recargos.

**Datos de prueba:**
{ "modu": 11, "rec": 1, "fol1": 1000, "fol2": 2000 }

---

## Caso de Uso 2: Consulta de información de oficina (recaudadora/zona)

**Descripción:** El usuario consulta los datos de la oficina asociada a la recaudadora seleccionada.

**Precondiciones:**
El usuario ya realizó una consulta de reporte y la recaudadora existe.

**Pasos a seguir:**
1. Realizar una consulta de reporte con recaudadora 2.
2. Presionar el botón 'Ver Info Oficina'.

**Resultado esperado:**
Se muestra la información de la recaudadora y zona: nombre, domicilio, teléfono, recaudador, sector.

**Datos de prueba:**
{ "reca": 2 }

---

## Caso de Uso 3: Consulta con rango de folios sin datos

**Descripción:** El usuario consulta un rango de folios donde no existen registros.

**Precondiciones:**
El rango de folios no tiene registros en la base de datos.

**Pasos a seguir:**
1. Acceder a la página de reporte.
2. Seleccionar cualquier módulo.
3. Ingresar recaudadora 1.
4. Ingresar folio inicial 999999 y folio final 999999.
5. Presionar 'Consultar'.

**Resultado esperado:**
Se muestra la tabla vacía o un mensaje indicando que no hay datos para los parámetros seleccionados.

**Datos de prueba:**
{ "modu": 11, "rec": 1, "fol1": 999999, "fol2": 999999 }

---

