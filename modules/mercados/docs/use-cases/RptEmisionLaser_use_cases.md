# Casos de Uso - RptEmisionLaser

**Categoría:** Form

## Caso de Uso 1: Generar reporte de emisión laser para un mercado específico

**Descripción:** El usuario desea obtener el reporte de adeudos de locales para la oficina 2, año 2024, periodo 6 (junio), mercado 3.

**Precondiciones:**
El usuario tiene permisos de consulta y existen datos de adeudos para los parámetros seleccionados.

**Pasos a seguir:**
1. El usuario accede a la página de emisión laser.
2. Selecciona Oficina: 2, Año: 2024, Periodo: 6, Mercado: 3.
3. Hace clic en 'Generar Reporte'.
4. El sistema consulta el backend y muestra la tabla de locales con adeudo.

**Resultado esperado:**
Se muestra una tabla con los locales adeudores, sus rentas, recargos, subtotal y meses de adeudo.

**Datos de prueba:**
{ "oficina": 2, "axo": 2024, "periodo": 6, "mercado": 3 }

---

## Caso de Uso 2: Consultar detalle de pagos y requerimientos de un local

**Descripción:** El usuario desea ver el detalle de pagos, meses de adeudo y requerimientos de un local específico desde el reporte.

**Precondiciones:**
El reporte de emisión laser ya fue generado y el local tiene pagos y requerimientos registrados.

**Pasos a seguir:**
1. El usuario hace clic en 'Detalle' en la fila del local deseado.
2. El sistema consulta los pagos, meses de adeudo y requerimientos vía API.
3. Se muestra un modal con la información detallada.

**Resultado esperado:**
El usuario visualiza los pagos realizados, los meses de adeudo y los requerimientos asociados al local.

**Datos de prueba:**
{ "id_local": 123, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 3: Obtener fecha de descuento para un mes

**Descripción:** El usuario necesita saber la fecha límite de descuento para el mes de junio.

**Precondiciones:**
La tabla de fechas de descuento está actualizada.

**Pasos a seguir:**
1. El frontend solicita la fecha de descuento para el mes 6 vía API.
2. El backend retorna la fecha correspondiente.

**Resultado esperado:**
Se muestra la fecha de descuento y la fecha de recargos para el mes solicitado.

**Datos de prueba:**
{ "mes": 6 }

---

