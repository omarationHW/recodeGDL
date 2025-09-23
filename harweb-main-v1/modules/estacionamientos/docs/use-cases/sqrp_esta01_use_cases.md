# Casos de Uso - sqrp_esta01

**Categoría:** Form

## Caso de Uso 1: Consulta general del informe de multas sin filtros

**Descripción:** El usuario accede a la página del informe y consulta todos los registros disponibles, sin aplicar filtros de año.

**Precondiciones:**
Existen registros en las tablas ta14_folios_adeudo y ta14_tarifas.

**Pasos a seguir:**
1. El usuario ingresa a la página del informe.
2. No ingresa ningún filtro de año.
3. Da clic en 'Consultar'.
4. El sistema muestra el reporte agrupado por año e infracción.

**Resultado esperado:**
Se muestran todos los años e infracciones con sus totales de folios e importes.

**Datos de prueba:**
ta14_folios_adeudo: registros de varios años e infracciones; ta14_tarifas: tarifas correspondientes.

---

## Caso de Uso 2: Consulta filtrando por rango de años

**Descripción:** El usuario filtra el informe para mostrar solo los registros entre 2021 y 2022.

**Precondiciones:**
Existen registros para los años 2020, 2021, 2022 y 2023.

**Pasos a seguir:**
1. El usuario ingresa a la página del informe.
2. Ingresa '2021' en 'Año desde' y '2022' en 'Año hasta'.
3. Da clic en 'Consultar'.
4. El sistema muestra solo los registros de 2021 y 2022.

**Resultado esperado:**
Solo se muestran los años 2021 y 2022 con sus totales.

**Datos de prueba:**
ta14_folios_adeudo: registros para 2020-2023; ta14_tarifas: tarifas correspondientes.

---

## Caso de Uso 3: Consulta sin resultados (filtros fuera de rango)

**Descripción:** El usuario filtra por un rango de años donde no existen registros.

**Precondiciones:**
No existen registros para el año 1999.

**Pasos a seguir:**
1. El usuario ingresa a la página del informe.
2. Ingresa '1999' en 'Año desde' y '1999' en 'Año hasta'.
3. Da clic en 'Consultar'.
4. El sistema muestra mensaje de 'No hay datos para los filtros seleccionados.'

**Resultado esperado:**
No se muestran registros y aparece mensaje de advertencia.

**Datos de prueba:**
ta14_folios_adeudo: sin registros para 1999.

---

