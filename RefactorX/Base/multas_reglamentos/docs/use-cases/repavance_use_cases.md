# Casos de Uso - repavance

**Categoría:** Form

## Caso de Uso 1: Generar reporte mensual de multas municipales

**Descripción:** El usuario desea obtener el reporte de avance de recaudación de multas municipales para el mes de enero de 2024 en la recaudadora 1.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar 'Enero' como mes.
3. Ingresar '2024' como año.
4. Ingresar '1' como ID de recaudadora.
5. Seleccionar 'Municipal' como tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con el detalle de actas e importes por dependencia para el mes de enero 2024, tipo municipal.

**Datos de prueba:**
{ "mes": 0, "anio": 2024, "recaudadora_id": 1, "tipo": "M" }

---

## Caso de Uso 2: Generar reporte mensual de multas federales

**Descripción:** El usuario desea obtener el reporte de avance de recaudación de multas federales para el mes de febrero de 2024 en la recaudadora 2.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID de la recaudadora.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar 'Febrero' como mes.
3. Ingresar '2024' como año.
4. Ingresar '2' como ID de recaudadora.
5. Seleccionar 'Federal' como tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
Se muestra una tabla con el detalle de actas e importes por dependencia para el mes de febrero 2024, tipo federal.

**Datos de prueba:**
{ "mes": 1, "anio": 2024, "recaudadora_id": 2, "tipo": "F" }

---

## Caso de Uso 3: Validación de parámetros insuficientes

**Descripción:** El usuario intenta generar un reporte sin ingresar el año.

**Precondiciones:**
El usuario accede a la página pero deja el campo año vacío.

**Pasos a seguir:**
1. Acceder a la página de Avance de Recaudación de Multas.
2. Seleccionar un mes.
3. Dejar el campo año vacío.
4. Ingresar un ID de recaudadora.
5. Seleccionar un tipo.
6. Hacer clic en 'Generar Reporte'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que faltan parámetros.

**Datos de prueba:**
{ "mes": 0, "anio": null, "recaudadora_id": 1, "tipo": "M" }

---

