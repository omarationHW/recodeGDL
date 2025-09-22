# Casos de Uso - EmisionLibertad

**Categoría:** Form

## Caso de Uso 1: Generar Emisión para un Mercado con Caja de Cobro

**Descripción:** El usuario desea generar la emisión de recibos para el mercado 5 de la recaudadora 1 para el mes de junio de 2024.

**Precondiciones:**
El usuario está autenticado y tiene permisos para emitir recibos. Existen locales activos en el mercado 5.

**Pasos a seguir:**
- Acceder a la página de Emisión Libertad.
- Seleccionar año 2024 y periodo 6 (junio).
- Seleccionar recaudadora 1.
- Seleccionar mercado 5.
- Hacer clic en 'Generar Emisión'.

**Resultado esperado:**
Se muestra una tabla con el detalle de la emisión para todos los locales del mercado 5, incluyendo renta, adeudos, recargos, multas, gastos y folios de requerimientos.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---

## Caso de Uso 2: Exportar Archivo TXT de Emisión

**Descripción:** El usuario desea exportar el archivo TXT de la emisión generada para los mercados 5 y 6 de la recaudadora 1.

**Precondiciones:**
La emisión ya fue generada y está disponible en pantalla.

**Pasos a seguir:**
- Hacer clic en 'Exportar TXT'.

**Resultado esperado:**
Se descarga un archivo TXT con el layout especificado, listo para ser entregado a caja.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5,6], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---

## Caso de Uso 3: Visualizar Detalle de Emisión para Varios Mercados

**Descripción:** El usuario desea ver el detalle de emisión para los mercados 5 y 6 de la recaudadora 1.

**Precondiciones:**
El usuario está autenticado y tiene acceso a los mercados seleccionados.

**Pasos a seguir:**
- Seleccionar año 2024 y periodo 6.
- Seleccionar recaudadora 1.
- Seleccionar mercados 5 y 6.
- Hacer clic en 'Generar Emisión'.

**Resultado esperado:**
Se muestra la tabla con el detalle de todos los locales de los mercados seleccionados.

**Datos de prueba:**
{ "oficina": 1, "mercados": [5,6], "axo": 2024, "periodo": 6, "usuario_id": 1 }

---

