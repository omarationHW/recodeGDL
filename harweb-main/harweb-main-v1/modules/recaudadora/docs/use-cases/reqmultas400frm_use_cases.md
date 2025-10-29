# Casos de Uso - reqmultas400frm

**Categoría:** Form

## Caso de Uso 1: Consulta por Acta - Multa Federal

**Descripción:** El usuario desea consultar los requerimientos de multas federales por dependencia, año y número de acta.

**Precondiciones:**
El usuario tiene acceso a la página y conoce los datos de dependencia, año y número de acta.

**Pasos a seguir:**
1. Seleccionar 'Multas Federales'.
2. Ingresar 'DEP' en Dependencia.
3. Ingresar '2023' en Año de Acta.
4. Ingresar '12345' en Número de Acta.
5. Presionar 'Buscar por Acta'.

**Resultado esperado:**
Se muestra una tabla con los registros de la tabla req_mul_400 que cumplen los criterios.

**Datos de prueba:**
{ dep: 'DEP', axo: 2023, numacta: 12345, tipo: 6 }

---

## Caso de Uso 2: Consulta por Folio - Multa Municipal

**Descripción:** El usuario desea consultar los requerimientos de multas municipales por año y folio de requerimiento.

**Precondiciones:**
El usuario tiene acceso a la página y conoce el año y folio de requerimiento.

**Pasos a seguir:**
1. Seleccionar 'Multas Municipales'.
2. Ingresar '2022' en Año req.
3. Ingresar '54321' en Folio req.
4. Presionar 'Buscar por Folio Req'.

**Resultado esperado:**
Se muestra una tabla con los registros de la tabla req_mul_400 que cumplen los criterios.

**Datos de prueba:**
{ axo: 2022, folio: 54321, tipo: 5 }

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario realiza una consulta con datos que no existen en la base.

**Precondiciones:**
El usuario accede a la página y realiza una búsqueda con datos inexistentes.

**Pasos a seguir:**
1. Seleccionar cualquier tipo de multa.
2. Ingresar valores inexistentes en los campos requeridos.
3. Presionar el botón de búsqueda correspondiente.

**Resultado esperado:**
Se muestra el mensaje 'No se encontraron resultados.'

**Datos de prueba:**
{ dep: 'ZZZ', axo: 1900, numacta: 99999, tipo: 6 }

---

