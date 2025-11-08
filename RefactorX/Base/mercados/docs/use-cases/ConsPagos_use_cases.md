# Casos de Uso - ConsPagos

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de un local

**Descripción:** El usuario desea ver todos los pagos realizados para un local específico.

**Precondiciones:**
El usuario tiene acceso al sistema y conoce el ID del local.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Ingresa el ID del local en el campo correspondiente.
3. Presiona el botón 'Buscar'.
4. El sistema muestra la lista de pagos asociados al local.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para el local, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
id_local: 12345

---

## Caso de Uso 2: Agregar un nuevo pago a un local

**Descripción:** El usuario necesita registrar un nuevo pago para un local.

**Precondiciones:**
El usuario tiene permisos para agregar pagos y conoce los datos requeridos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Ingresa el ID del local y busca los pagos existentes.
3. Presiona el botón 'Agregar Pago'.
4. Llena el formulario con los datos del pago (año, mes, fecha, oficina, caja, operación, importe, partida).
5. Presiona 'Agregar'.
6. El sistema registra el pago y actualiza la tabla.

**Resultado esperado:**
El nuevo pago aparece en la tabla de pagos del local.

**Datos de prueba:**
{
  "id_local": 12345,
  "axo": 2024,
  "periodo": 6,
  "fecha_pago": "2024-06-15",
  "oficina_pago": 2,
  "caja_pago": "A",
  "operacion_pago": 1001,
  "importe_pago": 1500.00,
  "folio": "F1234",
  "id_usuario": 1
}

---

## Caso de Uso 3: Eliminar un pago existente

**Descripción:** El usuario necesita eliminar un pago registrado por error.

**Precondiciones:**
El usuario tiene permisos para eliminar pagos.

**Pasos a seguir:**
1. El usuario accede a la página de Consulta de Pagos.
2. Busca los pagos de un local.
3. Identifica el pago a eliminar y presiona el botón 'Eliminar'.
4. Confirma la eliminación en el diálogo.
5. El sistema elimina el pago y actualiza la tabla.

**Resultado esperado:**
El pago seleccionado ya no aparece en la tabla.

**Datos de prueba:**
id_pago_local: 98765

---

