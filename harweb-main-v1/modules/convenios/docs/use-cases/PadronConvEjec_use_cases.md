# Casos de Uso - PadronConvEjec

**Categoría:** Form

## Caso de Uso 1: Consulta de convenios por ejecutor y año

**Descripción:** El usuario desea consultar todos los convenios de tipo 1, subtipo 1, recaudadora ZC1, vigentes, ejecutados por el ejecutor 6, entre los años 2013 y 2015.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página PadronConvEjec.
2. Selecciona Tipo: 1, Subtipo: 1, Recaudadora: ZC1, Vigencia: Vigentes, Ejecutor: 6, Año inicio: 2013, Año fin: 2015.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con los convenios filtrados según los criterios seleccionados, incluyendo folio, ejecutor, fechas, pagos y periodos.

**Datos de prueba:**
tipo: 1, subtipo: 1, recaudadora: 1 (ZC1), vigencia: 'A', ejecutor: 6, anio_ini: 2013, anio_fin: 2015

---

## Caso de Uso 2: Exportación de convenios a Excel

**Descripción:** El usuario desea exportar a Excel todos los convenios de tipo 3, cualquier subtipo, todas las recaudadoras, cualquier ejecutor, vigencia 'Pagados', entre 2010 y 2020.

**Precondiciones:**
El usuario está autenticado y tiene permisos de exportación.

**Pasos a seguir:**
1. El usuario accede a la página PadronConvEjec.
2. Selecciona Tipo: 3, Subtipo: 000, Recaudadora: 000, Vigencia: 'P', Ejecutor: 000, Año inicio: 2010, Año fin: 2020.
3. Presiona el botón 'Exportar Excel'.

**Resultado esperado:**
Se genera y descarga un archivo Excel con los convenios filtrados.

**Datos de prueba:**
tipo: 3, subtipo: 000, recaudadora: 000, vigencia: 'P', ejecutor: 000, anio_ini: 2010, anio_fin: 2020

---

## Caso de Uso 3: Consulta sin resultados

**Descripción:** El usuario realiza una consulta con filtros que no tienen coincidencias.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario accede a la página PadronConvEjec.
2. Selecciona Tipo: 99 (no existe), Subtipo: 000, Recaudadora: 000, Vigencia: 'A', Ejecutor: 000, Año inicio: 2050, Año fin: 2051.
3. Presiona el botón 'Buscar'.

**Resultado esperado:**
Se muestra el mensaje 'No hay resultados.' en la tabla.

**Datos de prueba:**
tipo: 99, subtipo: 000, recaudadora: 000, vigencia: 'A', ejecutor: 000, anio_ini: 2050, anio_fin: 2051

---

