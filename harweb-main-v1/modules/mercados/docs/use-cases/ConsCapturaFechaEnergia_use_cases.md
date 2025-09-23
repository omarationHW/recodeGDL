# Casos de Uso - ConsCapturaFechaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de Pagos de Energía por Fecha y Oficina

**Descripción:** El usuario consulta todos los pagos capturados de energía eléctrica para una fecha, oficina, caja y operación específica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta.

**Pasos a seguir:**
1. El usuario accede a la página de consulta.
2. Selecciona la fecha, oficina, caja y operación.
3. Presiona 'Buscar'.
4. El sistema muestra la lista de pagos encontrados.

**Resultado esperado:**
Se muestra una tabla con los pagos capturados que cumplen los filtros.

**Datos de prueba:**
{ "fecha_pago": "2024-06-01", "oficina_pago": 1, "caja_pago": "A", "operacion_pago": 12345 }

---

## Caso de Uso 2: Eliminación de Pagos Seleccionados

**Descripción:** El usuario selecciona uno o varios pagos y los elimina. El sistema regenera el adeudo si corresponde.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario realiza una búsqueda de pagos.
2. Selecciona uno o varios pagos en la tabla.
3. Presiona 'Borrar Pago(s)'.
4. Confirma la acción.
5. El sistema elimina los pagos y regenera adeudos si es necesario.

**Resultado esperado:**
Los pagos seleccionados son eliminados y los adeudos se regeneran si no existen.

**Datos de prueba:**
{ "pagos_ids": [101, 102], "fecha_pago": "2024-06-01", "oficina_pago": 1, "operacion_pago": 12345 }

---

## Caso de Uso 3: Carga de Cajas por Oficina

**Descripción:** El usuario selecciona una oficina y el sistema carga automáticamente las cajas disponibles.

**Precondiciones:**
El usuario está autenticado.

**Pasos a seguir:**
1. El usuario selecciona una oficina en el filtro.
2. El sistema consulta y muestra las cajas asociadas a esa oficina.

**Resultado esperado:**
El select de cajas se llena con las cajas correspondientes a la oficina seleccionada.

**Datos de prueba:**
{ "oficina": 1 }

---

