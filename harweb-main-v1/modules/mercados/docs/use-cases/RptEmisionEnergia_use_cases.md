# Casos de Uso - RptEmisionEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Recibos de Energía para Mercado de Abastos

**Descripción:** El usuario desea consultar los recibos de energía eléctrica emitidos para el Mercado de Abastos en la oficina Cruz del Sur para el mes de junio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos para consultar reportes. Existen datos de energía para el mercado y periodo seleccionados.

**Pasos a seguir:**
- El usuario accede a la página de Emisión de Recibos de Energía.
- Selecciona 'Cruz del Sur' como oficina.
- Selecciona 'Mercado de Abastos' como mercado.
- Selecciona año 2024 y periodo 6 (junio).
- Hace clic en 'Consultar'.

**Resultado esperado:**
Se muestra una tabla con los recibos de energía correspondientes, incluyendo datos de locales, nombre, descripción, cuenta de energía, kilowhatts, importe y tipo de consumo.

**Datos de prueba:**
{ "oficina": 5, "mercado": 1, "axo": 2024, "periodo": 6 }

---

## Caso de Uso 2: Impresión de Recibos de Energía

**Descripción:** El usuario desea imprimir el reporte de recibos de energía para el Mercado Libertad en mayo de 2023.

**Precondiciones:**
El usuario está autenticado y tiene permisos de impresión. Existen datos para el mercado y periodo.

**Pasos a seguir:**
- Accede a la página de Emisión de Recibos de Energía.
- Selecciona 'Cruz del Sur' como oficina.
- Selecciona 'Mercado Libertad' como mercado.
- Selecciona año 2023 y periodo 5 (mayo).
- Hace clic en 'Consultar'.
- Hace clic en 'Imprimir'.

**Resultado esperado:**
Se genera y descarga (o muestra) un PDF con el reporte de recibos de energía para los parámetros seleccionados.

**Datos de prueba:**
{ "oficina": 5, "mercado": 2, "axo": 2023, "periodo": 5 }

---

## Caso de Uso 3: Manejo de Parámetros Inválidos

**Descripción:** El usuario intenta consultar recibos de energía sin seleccionar todos los parámetros requeridos.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
- Accede a la página de Emisión de Recibos de Energía.
- Deja vacío el campo 'Mercado'.
- Hace clic en 'Consultar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que todos los campos son obligatorios.

**Datos de prueba:**
{ "oficina": 5, "mercado": "", "axo": 2024, "periodo": 6 }

---

