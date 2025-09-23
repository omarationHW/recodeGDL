# Casos de Uso - listanotificacionesfrm

**Categoría:** Form

## Caso de Uso 1: Consulta de Notificaciones por Lote

**Descripción:** El usuario desea obtener el listado de notificaciones de multas para una recaudadora y año específicos, filtrando por un rango de folios y ordenando por número de lote.

**Precondiciones:**
El usuario tiene acceso al sistema y existen registros en las tablas reqmultas, multas y c_dependencias que cumplen los criterios.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 2).
2. Ingresar el año (ej. 2024).
3. Ingresar el folio inicial (ej. 1000).
4. Ingresar el folio final (ej. 2000).
5. Seleccionar 'Notificación' como tipo de documento.
6. Seleccionar 'Número de lote' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las columnas: Dependencia, Año Acta, Número Acta, Número Lote, Folio Req, ordenada por número de lote y acta. El total de actas se muestra al pie.

**Datos de prueba:**
{ "reca": 2, "axo": 2024, "inicio": 1000, "final": 2000, "tipo": "N", "orden": "lote" }

---

## Caso de Uso 2: Consulta de Requerimientos Vigentes

**Descripción:** El usuario desea obtener solo los requerimientos de multas vigentes (no pagadas ni canceladas) en un rango de folios.

**Precondiciones:**
Existen registros de requerimientos con cvepago y fecha_cancelacion en NULL.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 3).
2. Ingresar el año (ej. 2023).
3. Ingresar el folio inicial (ej. 5000).
4. Ingresar el folio final (ej. 6000).
5. Seleccionar 'Requerimiento' como tipo de documento.
6. Seleccionar 'Folio de notificación (solo vigentes)' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los requerimientos vigentes, ordenada por folio de notificación.

**Datos de prueba:**
{ "reca": 3, "axo": 2023, "inicio": 5000, "final": 6000, "tipo": "R", "orden": "vigentes" }

---

## Caso de Uso 3: Consulta de Secuestros por Dependencia y Número de Acta

**Descripción:** El usuario desea obtener el listado de secuestros de multas, ordenado por dependencia y número de acta.

**Precondiciones:**
Existen registros de secuestros en el rango de folios indicado.

**Pasos a seguir:**
1. Ingresar el número de recaudadora (ej. 1).
2. Ingresar el año (ej. 2022).
3. Ingresar el folio inicial (ej. 7000).
4. Ingresar el folio final (ej. 8000).
5. Seleccionar 'Secuestro' como tipo de documento.
6. Seleccionar 'Dependencia y número de acta' como orden.
7. Hacer clic en 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con los secuestros, ordenada por dependencia, año de acta y número de acta.

**Datos de prueba:**
{ "reca": 1, "axo": 2022, "inicio": 7000, "final": 8000, "tipo": "S", "orden": "dependencia" }

---

