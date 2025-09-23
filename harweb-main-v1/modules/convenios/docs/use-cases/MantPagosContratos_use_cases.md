# Casos de Uso - MantPagosContratos

**Categoría:** Form

## Caso de Uso 1: Agregar un nuevo pago de contrato

**Descripción:** El usuario desea registrar un nuevo pago para un contrato existente.

**Precondiciones:**
El contrato (colonia, calle, folio) debe existir. El usuario debe estar autenticado.

**Pasos a seguir:**
1. El usuario ingresa a la página de Pagos de Contratos.
2. Llena los campos de fecha, oficina, caja y operación y presiona 'Buscar'.
3. El sistema indica que no existe el pago y habilita el formulario de alta.
4. El usuario ingresa colonia, calle, folio, parcialidad, total parcialidades, importe, descuento y bonificación.
5. Presiona 'Agregar'.
6. El sistema valida y registra el pago.

**Resultado esperado:**
El pago se registra correctamente y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "fecha_pago": "2024-06-01",
  "oficina_pago": 1,
  "caja_pago": "A",
  "operacion_pago": 12345,
  "colonia": 10,
  "calle": 5,
  "folio": 1001,
  "pago_parcial": 1,
  "total_parciales": 12,
  "importe": 1500.00,
  "cve_descuento": 0,
  "cve_bonificacion": 0,
  "id_usuario": 1
}

---

## Caso de Uso 2: Modificar un pago existente

**Descripción:** El usuario necesita corregir el importe de un pago ya registrado.

**Precondiciones:**
El pago debe existir. El usuario debe tener permisos de modificación.

**Pasos a seguir:**
1. El usuario busca el pago por fecha, oficina, caja y operación.
2. El sistema muestra los datos del pago.
3. El usuario modifica el campo 'importe' y presiona 'Modificar'.
4. El sistema valida y actualiza el registro.

**Resultado esperado:**
El pago es actualizado y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "fecha_pago": "2024-06-01",
  "oficina_pago": 1,
  "caja_pago": "A",
  "operacion_pago": 12345,
  "colonia": 10,
  "calle": 5,
  "folio": 1001,
  "pago_parcial": 1,
  "total_parciales": 12,
  "importe": 2000.00,
  "cve_descuento": 0,
  "cve_bonificacion": 0,
  "id_usuario": 1
}

---

## Caso de Uso 3: Eliminar un pago de contrato

**Descripción:** El usuario desea eliminar un pago registrado por error.

**Precondiciones:**
El pago debe existir. El usuario debe tener permisos de eliminación.

**Pasos a seguir:**
1. El usuario busca el pago por fecha, oficina, caja y operación.
2. El sistema muestra los datos del pago.
3. El usuario presiona 'Borrar'.
4. El sistema elimina el pago.

**Resultado esperado:**
El pago es eliminado y se muestra un mensaje de éxito.

**Datos de prueba:**
{
  "fecha_pago": "2024-06-01",
  "oficina_pago": 1,
  "caja_pago": "A",
  "operacion_pago": 12345
}

---

