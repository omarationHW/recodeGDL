# Casos de Uso - ConsPagosLocales

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos por local específico

**Descripción:** El usuario desea consultar todos los pagos realizados para un local específico, ingresando recaudadora, mercado, sección, local, letra y bloque.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos registrados para el local.

**Pasos a seguir:**
1. Ingresar a la página de Consulta de Pagos del Local.
2. Seleccionar 'Por Local'.
3. Seleccionar la recaudadora, mercado, sección, ingresar categoría, número de local, letra y bloque.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para ese local, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 10, "categoria": 2, "seccion": "A", "local": 5, "letra_local": "B", "bloque": "C" }

---

## Caso de Uso 2: Consulta de pagos por fecha de pago

**Descripción:** El usuario desea ver todos los pagos realizados en una fecha específica, filtrando por oficina, caja y operación.

**Precondiciones:**
El usuario tiene acceso al sistema y existen pagos en la fecha indicada.

**Pasos a seguir:**
1. Ingresar a la página de Consulta de Pagos del Local.
2. Seleccionar 'Por Fecha de Pago'.
3. Seleccionar la fecha, oficina, caja y operación.
4. Presionar 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados en esa fecha y filtros.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 2, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 3: Validación de campos obligatorios

**Descripción:** El usuario intenta buscar pagos sin seleccionar ningún filtro.

**Precondiciones:**
El usuario está en la página de Consulta de Pagos del Local.

**Pasos a seguir:**
1. No seleccionar ningún filtro.
2. Presionar 'Buscar'.

**Resultado esperado:**
El sistema muestra un mensaje de error indicando que debe seleccionar una opción de búsqueda.

**Datos de prueba:**
{}

---

