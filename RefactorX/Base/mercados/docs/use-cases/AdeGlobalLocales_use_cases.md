# Casos de Uso - AdeGlobalLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudo Global con Accesorios

**Descripción:** El usuario consulta el listado de locales con adeudo global y accesorios para una oficina y mercado específicos.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudo Global con Accesorios'.
2. Selecciona la oficina 'Zona Centro'.
3. Selecciona el mercado '14 - Mercado Abastos'.
4. Selecciona el año 2024 y mes 6.
5. Hace clic en 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los locales que tienen adeudo y accesorios para los filtros seleccionados.

**Datos de prueba:**
office_id: 1, market_id: 14, year: 2024, month: 6

---

## Caso de Uso 2: Exportar a Excel el listado de locales con adeudo

**Descripción:** El usuario exporta a Excel el listado de locales con adeudo global y accesorios.

**Precondiciones:**
El usuario ya realizó una consulta y hay resultados en pantalla.

**Pasos a seguir:**
1. El usuario hace clic en el botón 'Excel 1'.

**Resultado esperado:**
Se descarga un archivo Excel con los datos mostrados en la tabla de locales con adeudo.

**Datos de prueba:**
office_id: 1, market_id: 14, year: 2024, month: 6

---

## Caso de Uso 3: Consulta de Locales sin Adeudo pero con Accesorios

**Descripción:** El usuario consulta el listado de locales que no tienen adeudo pero sí accesorios.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. El usuario accede a la página 'Adeudo Global con Accesorios'.
2. Selecciona la oficina y mercado deseados.
3. Selecciona año y mes.
4. Hace clic en 'Locales sin Adeudo con Accesorios'.

**Resultado esperado:**
Se muestra una tabla con los locales sin adeudo pero con accesorios.

**Datos de prueba:**
market_id: 14, year: 2024, month: 6

---

