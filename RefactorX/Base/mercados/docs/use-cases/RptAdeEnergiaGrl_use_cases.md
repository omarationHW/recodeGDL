# Casos de Uso - RptAdeEnergiaGrl

**Categoría:** Form

## Caso de Uso 1: Consulta de Adeudos Globales de Energía

**Descripción:** El usuario desea consultar los adeudos globales de energía eléctrica de un mercado específico para un año y mes determinados.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de Adeudos Globales de Energía.
2. Selecciona la recaudadora (oficina).
3. Selecciona el mercado.
4. Selecciona el año y el mes.
5. Presiona el botón 'Consultar'.
6. El sistema muestra la tabla de adeudos.

**Resultado esperado:**
Se muestra la lista de locales con sus adeudos, meses de adeudo y cuota correspondiente.

**Datos de prueba:**
office_id: 1, market_id: 5, year: 2024, month: 6

---

## Caso de Uso 2: Exportación de Adeudos a Excel

**Descripción:** El usuario desea exportar el listado de adeudos globales de energía a un archivo Excel.

**Precondiciones:**
El usuario ya realizó una consulta y hay datos en pantalla.

**Pasos a seguir:**
1. El usuario presiona el botón 'Exportar Excel'.
2. El sistema genera y descarga el archivo Excel con los datos mostrados.

**Resultado esperado:**
El archivo Excel contiene los mismos datos que la tabla en pantalla.

**Datos de prueba:**
office_id: 2, market_id: 10, year: 2023, month: 12

---

## Caso de Uso 3: Validación de Filtros Obligatorios

**Descripción:** El usuario intenta consultar sin seleccionar todos los filtros requeridos.

**Precondiciones:**
El usuario está en la página de Adeudos Globales de Energía.

**Pasos a seguir:**
1. El usuario deja uno o más filtros vacíos.
2. Presiona 'Consultar'.
3. El sistema muestra un mensaje de error.

**Resultado esperado:**
El sistema no realiza la consulta y muestra un mensaje indicando que todos los filtros son obligatorios.

**Datos de prueba:**
office_id: '', market_id: '', year: '', month: ''

---

