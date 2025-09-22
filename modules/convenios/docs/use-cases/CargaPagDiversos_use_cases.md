# Casos de Uso - CargaPagDiversos

**Categoría:** Form

## Caso de Uso 1: Carga de pagos diversos para una recaudadora propia

**Descripción:** El usuario consulta y carga pagos diversos de su propia recaudadora en un rango de fechas.

**Precondiciones:**
El usuario está autenticado y tiene nivel de acceso 2 (solo su recaudadora). Existen pagos diversos pendientes en el rango de fechas.

**Pasos a seguir:**
1. El usuario accede a la página de Carga Pagos Diversos.
2. Selecciona un rango de fechas y su recaudadora.
3. Presiona 'Buscar'.
4. Se muestran los pagos pendientes.
5. Selecciona uno o varios pagos y presiona 'Grabar Pagos Seleccionados'.

**Resultado esperado:**
Los pagos seleccionados se graban correctamente en la tabla de pagos. Se muestra mensaje de éxito.

**Datos de prueba:**
Usuario: recaudadora=3, nivel=2; fechas: 2024-06-01 a 2024-06-10; pagos diversos existentes.

---

## Caso de Uso 2: Intento de carga de pagos de otra recaudadora sin permisos

**Descripción:** El usuario intenta cargar pagos de una recaudadora diferente sin tener nivel 1.

**Precondiciones:**
El usuario está autenticado con nivel 2. Intenta seleccionar recaudadora distinta a la suya.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona fechas y una recaudadora diferente.
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema rechaza la operación y muestra mensaje de error de autorización.

**Datos de prueba:**
Usuario: recaudadora=2, nivel=2; selecciona recaudadora=1.

---

## Caso de Uso 3: Carga de pagos diversos con contrato inexistente

**Descripción:** El usuario selecciona pagos diversos que no tienen contrato destino válido.

**Precondiciones:**
El usuario está autenticado y autorizado. Existen pagos diversos con colonia/calle/folio que no corresponden a ningún contrato.

**Pasos a seguir:**
1. El usuario busca pagos diversos.
2. Selecciona pagos con datos inválidos.
3. Presiona 'Grabar Pagos Seleccionados'.

**Resultado esperado:**
El sistema muestra error indicando que no existe el contrato para los pagos seleccionados. No se graba ningún pago.

**Datos de prueba:**
Pago con colonia=999, calle=999, folio=999 (no existe contrato).

---

