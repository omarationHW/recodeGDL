# Casos de Uso - trasladosfrm

**Categoría:** Form

## Caso de Uso 1: Búsqueda de un pago existente

**Descripción:** El usuario ingresa los datos de un pago y verifica si existe en el sistema.

**Precondiciones:**
El pago debe existir en la tabla pagos con los datos correctos.

**Pasos a seguir:**
1. Ingresar recaud, folio, caja, fecha e importe.
2. Presionar 'Buscar pago'.

**Resultado esperado:**
Se muestran los detalles del pago y sus requerimientos asociados.

**Datos de prueba:**
{ recaud: '001', folio: '12345', caja: 'A1', fecha: '2024-06-01', importe: 1500.00 }

---

## Caso de Uso 2: Aplicar traslado a futuros pagos

**Descripción:** El usuario aplica el traslado de un pago erróneo a futuros pagos.

**Precondiciones:**
El pago debe estar previamente buscado y encontrado.

**Pasos a seguir:**
1. Buscar el pago.
2. Seleccionar 'Futuros pagos' como tipo de aplicación.
3. Ingresar usuario.
4. Presionar 'Aplicar'.

**Resultado esperado:**
El sistema confirma que el traslado fue aplicado a futuros pagos.

**Datos de prueba:**
{ pago_id: 1001, tipo_aplicacion: 'futuros', usuario: 'admin' }

---

## Caso de Uso 3: Liquidar un pago

**Descripción:** El usuario liquida un pago previamente encontrado.

**Precondiciones:**
El pago debe estar previamente buscado y encontrado.

**Pasos a seguir:**
1. Buscar el pago.
2. Presionar el botón 'Liquidar'.

**Resultado esperado:**
El sistema confirma que el pago fue liquidado correctamente.

**Datos de prueba:**
{ pago_id: 1001, usuario: 'admin' }

---

