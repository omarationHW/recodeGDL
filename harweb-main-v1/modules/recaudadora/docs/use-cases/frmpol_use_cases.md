# Casos de Uso - frmpol

**Categoría:** Form

## Caso de Uso 1: Consulta de reporte de póliza para una recaudadora y fecha específica

**Descripción:** El usuario desea obtener el reporte de póliza para la recaudadora '003' correspondiente al día 2024-06-01.

**Precondiciones:**
El usuario tiene acceso al sistema y existen datos para la recaudadora '003' en la fecha indicada.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-06-01'.
3. Selecciona la recaudadora '003'.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
Se muestra una tabla con las cuentas de aplicación, descripción, total parcial y suma para la recaudadora '003' en la fecha seleccionada, junto con los totales generales.

**Datos de prueba:**
fecha: 2024-06-01, recaud: '003'

---

## Caso de Uso 2: Intento de consulta sin seleccionar recaudadora

**Descripción:** El usuario intenta generar el reporte sin seleccionar una recaudadora.

**Precondiciones:**
El usuario accede a la página y no selecciona recaudadora.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-06-01'.
3. No selecciona ninguna recaudadora.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
fecha: 2024-06-01, recaud: ''

---

## Caso de Uso 3: Consulta de reporte para fecha sin datos

**Descripción:** El usuario consulta el reporte para una fecha en la que no existen registros.

**Precondiciones:**
No existen pagos registrados para la recaudadora '001' en la fecha '2024-01-01'.

**Pasos a seguir:**
1. El usuario accede a la página de reporte de póliza.
2. Selecciona la fecha '2024-01-01'.
3. Selecciona la recaudadora '001'.
4. Presiona el botón 'Imprimir'.

**Resultado esperado:**
El sistema muestra un mensaje indicando que no se encontraron resultados para los criterios seleccionados.

**Datos de prueba:**
fecha: 2024-01-01, recaud: '001'

---

