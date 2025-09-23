# Casos de Uso - sfrm_consultapublicos

**Categoría:** Form

## Caso de Uso 1: Consulta de lista de estacionamientos públicos

**Descripción:** El usuario accede a la página principal y visualiza la lista completa de estacionamientos públicos registrados.

**Precondiciones:**
El usuario tiene acceso a la aplicación y existen registros en la tabla pubmain.

**Pasos a seguir:**
1. El usuario navega a /public-parking/list
2. El frontend realiza una petición POST a /api/execute con eRequest 'getPublicParkingList'.
3. El backend ejecuta el SP correspondiente y devuelve la lista.
4. El frontend muestra la tabla con los datos.

**Resultado esperado:**
Se muestra la lista completa de estacionamientos públicos con todos los campos relevantes.

**Datos de prueba:**
Registros de ejemplo en pubmain y pubcategoria.

---

## Caso de Uso 2: Consulta de adeudos de un estacionamiento

**Descripción:** El usuario selecciona un estacionamiento y visualiza sus adeudos.

**Precondiciones:**
El usuario está en la lista de estacionamientos y selecciona uno con adeudos.

**Pasos a seguir:**
1. El usuario hace clic en 'Adeudos' de un estacionamiento.
2. El frontend navega a /public-parking/debts/:pubid y realiza una petición POST a /api/execute con eRequest 'getPublicParkingDebts' y pubid.
3. El backend ejecuta el SP y devuelve los adeudos.
4. El frontend muestra la tabla de adeudos.

**Resultado esperado:**
Se muestran los conceptos, años, meses, adeudos y recargos del estacionamiento seleccionado.

**Datos de prueba:**
pubid=1234 con adeudos registrados en cajero_pub_detalle.

---

## Caso de Uso 3: Consulta de datos de licencia y totales

**Descripción:** El usuario consulta los datos generales y totales de una licencia de estacionamiento.

**Precondiciones:**
El usuario conoce el número de licencia y existen datos en las vistas/vistas SP correspondientes.

**Pasos a seguir:**
1. El usuario navega a /public-parking/license/:numlicencia.
2. El frontend realiza una petición POST a /api/execute con eRequest 'getLicenseGeneral' y numlicencia.
3. El backend ejecuta el SP y devuelve los datos generales de la licencia.
4. El frontend realiza una segunda petición con eRequest 'getLicenseTotals' usando el id de la licencia.
5. El frontend muestra los datos generales y la tabla de totales.

**Resultado esperado:**
Se muestran todos los datos generales de la licencia y los conceptos/importe asociados.

**Datos de prueba:**
numlicencia=56789 con datos en vw_licencias_generales y vw_licencias_totales.

---

