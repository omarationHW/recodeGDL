# Casos de Uso - Pagos_Con_FPgo

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por fecha de pago

**Descripción:** El usuario desea consultar todos los pagos realizados en una fecha específica y ver el detalle de cada pago.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados en la fecha consultada.

**Pasos a seguir:**
1. El usuario accede a la página 'Consulta de Pagos por Fecha de Pago'.
2. Selecciona la fecha deseada en el campo de fecha.
3. Presiona el botón 'Buscar'.
4. El sistema muestra una tabla con todos los pagos realizados en esa fecha.
5. El usuario puede hacer clic en 'Ver' para consultar el detalle del contrato relacionado.

**Resultado esperado:**
Se muestran todos los pagos realizados en la fecha seleccionada, con opción de ver el detalle del contrato.

**Datos de prueba:**
Fecha: 2024-06-01 (debe haber pagos en esa fecha)

---

## Caso de Uso 2: Consulta de pagos sin resultados

**Descripción:** El usuario consulta una fecha en la que no existen pagos registrados.

**Precondiciones:**
El usuario tiene acceso al sistema y la fecha consultada no tiene pagos.

**Pasos a seguir:**
1. El usuario accede a la página.
2. Selecciona una fecha sin pagos (ejemplo: 2023-01-01).
3. Presiona 'Buscar'.

**Resultado esperado:**
El sistema muestra la tabla vacía o un mensaje indicando que no hay pagos para esa fecha.

**Datos de prueba:**
Fecha: 2023-01-01 (sin pagos)

---

## Caso de Uso 3: Consulta de detalle de contrato

**Descripción:** El usuario consulta el detalle de un contrato desde la lista de pagos.

**Precondiciones:**
El usuario ya realizó una búsqueda de pagos y hay resultados.

**Pasos a seguir:**
1. El usuario hace clic en 'Ver' en la fila de un pago.
2. El sistema abre un modal mostrando el detalle del contrato.

**Resultado esperado:**
Se muestra la información detallada del contrato seleccionado.

**Datos de prueba:**
control_contrato: 1803 (debe existir en la base de datos)

---

