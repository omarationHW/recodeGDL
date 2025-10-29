# Casos de Uso - ConsPagosEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de energía por local

**Descripción:** El usuario desea consultar todos los pagos de energía realizados para un local específico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce los datos del local.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos de Energía.
2. Selecciona 'Por Local'.
3. Ingresa la recaudadora, mercado, categoría, sección, local, letra y bloque.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos de energía realizados para el local especificado.

**Datos de prueba:**
{ "oficina": 1, "num_mercado": 2, "categoria": 1, "seccion": "A", "local": 10, "letra_local": null, "bloque": null }

---

## Caso de Uso 2: Consulta de pagos de energía por fecha de pago

**Descripción:** El usuario desea consultar todos los pagos de energía realizados en una fecha específica.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce la fecha de pago.

**Pasos a seguir:**
1. Accede a la página de Consulta de Pagos de Energía.
2. Selecciona 'Por Fecha de Pago'.
3. Ingresa la fecha de pago, oficina, caja y operación.
4. Presiona 'Buscar'.

**Resultado esperado:**
Se muestra una tabla con todos los pagos de energía realizados en la fecha y criterios seleccionados.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 1, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 3: Listar recaudadoras y secciones para filtros

**Descripción:** El usuario necesita cargar los catálogos de recaudadoras y secciones para los filtros del formulario.

**Precondiciones:**
El usuario accede a la página de Consulta de Pagos de Energía.

**Pasos a seguir:**
1. Al cargar la página, el sistema solicita la lista de recaudadoras y secciones.
2. El backend responde con los catálogos.

**Resultado esperado:**
Los combos de recaudadora y sección se llenan correctamente.

**Datos de prueba:**
N/A

---

