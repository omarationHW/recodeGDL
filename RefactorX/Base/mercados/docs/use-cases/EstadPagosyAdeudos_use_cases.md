# Casos de Uso - EstadPagosyAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística de Pagos y Adeudos por Recaudadora

**Descripción:** El usuario desea obtener la estadística consolidada de pagos, capturas y adeudos de todos los mercados de una recaudadora para un periodo y rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar la recaudadora.

**Pasos a seguir:**
1. El usuario accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona la recaudadora 'Zona Centro'.
3. Selecciona el año 2024 y mes 6.
4. Selecciona el rango de fechas del 2024-06-01 al 2024-06-30.
5. Presiona 'Consultar'.
6. El sistema muestra la tabla con los resultados por mercado.

**Resultado esperado:**
Se muestra la tabla con los mercados, locales pagados, importes, periodos, capturas y adeudos.

**Datos de prueba:**
rec: 1, axo: 2024, mes: 6, fecdsd: '2024-06-01', fechst: '2024-06-30'

---

## Caso de Uso 2: Exportación de Estadística a Excel

**Descripción:** El usuario desea exportar la estadística consultada a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y tiene resultados en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar'.
2. El sistema inicia la exportación (no implementado en este ejemplo).

**Resultado esperado:**
Se muestra un mensaje indicando que la exportación está en proceso o no implementada.

**Datos de prueba:**
N/A

---

## Caso de Uso 3: Detalle de Locales de un Mercado

**Descripción:** El usuario desea ver el detalle de pagos y adeudos de los locales de un mercado específico.

**Precondiciones:**
El usuario ya realizó una consulta y seleccionó un mercado.

**Pasos a seguir:**
1. El usuario selecciona el mercado 'Mercado Centro'.
2. El sistema llama a la acción 'getMercadoDetalle' con los parámetros correspondientes.
3. El sistema muestra el listado de locales, pagos y adeudos.

**Resultado esperado:**
Se muestra el detalle de locales con sus pagos y adeudos.

**Datos de prueba:**
rec: 1, mercado: 1

---

