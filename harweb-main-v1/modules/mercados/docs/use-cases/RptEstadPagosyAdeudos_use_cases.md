# Casos de Uso - RptEstadPagosyAdeudos

**Categoría:** Form

## Caso de Uso 1: Consulta de Estadística de Pagos y Adeudos por Mercado

**Descripción:** El usuario desea obtener la estadística de pagos, capturas y adeudos de todos los mercados de la recaudadora Centro para el mes de junio de 2024.

**Precondiciones:**
El usuario tiene acceso al sistema y permisos para consultar reportes.

**Pasos a seguir:**
1. Accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona 'Centro' como recaudadora.
3. Selecciona el año 2024 y mes 6.
4. Selecciona el rango de fechas del 2024-06-01 al 2024-06-30.
5. Da clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los mercados de la recaudadora Centro y sus totales de pagos, capturas y adeudos.

**Datos de prueba:**
{ "id_rec": 1, "axo": 2024, "mes": 6, "fec3": "2024-06-01", "fec4": "2024-06-30" }

---

## Caso de Uso 2: Resumen Global de Pagos y Adeudos

**Descripción:** El usuario requiere un resumen global de pagos, capturas y adeudos para la recaudadora Olímpica en mayo de 2024.

**Precondiciones:**
El usuario tiene acceso y existen datos para la recaudadora Olímpica.

**Pasos a seguir:**
1. Accede a la página de Estadística de Pagos y Adeudos.
2. Selecciona 'Olímpica' como recaudadora.
3. Selecciona año 2024, mes 5.
4. Selecciona fechas del 2024-05-01 al 2024-05-31.
5. Solicita el resumen global.

**Resultado esperado:**
Se muestra el resumen de locales, importes y periodos para pagos, capturas y adeudos.

**Datos de prueba:**
{ "id_rec": 2, "axo": 2024, "mes": 5, "fec3": "2024-05-01", "fec4": "2024-05-31" }

---

## Caso de Uso 3: Validación de Parámetros Inválidos

**Descripción:** El usuario intenta consultar la estadística sin seleccionar recaudadora.

**Precondiciones:**
El usuario está autenticado pero no selecciona recaudadora.

**Pasos a seguir:**
1. Accede a la página.
2. Deja el campo recaudadora vacío.
3. Intenta consultar.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que la recaudadora es obligatoria.

**Datos de prueba:**
{ "id_rec": null, "axo": 2024, "mes": 6, "fec3": "2024-06-01", "fec4": "2024-06-30" }

---

