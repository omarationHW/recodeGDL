# Casos de Uso - PagosEneCons

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos de energía eléctrica por local

**Descripción:** El usuario desea consultar todos los pagos registrados para un local específico de energía eléctrica.

**Precondiciones:**
El usuario está autenticado y conoce el ID de energía del local.

**Pasos a seguir:**
1. El usuario accede a la página 'Pagos Energía Eléctrica'.
2. Ingresa el ID de energía en el formulario.
3. Presiona el botón 'Buscar'.
4. El sistema consulta los pagos vía API y muestra la tabla de resultados.

**Resultado esperado:**
Se muestra una tabla con todos los pagos realizados para el ID de energía especificado, incluyendo fecha, importe, usuario, etc.

**Datos de prueba:**
{ "id_energia": 123 }

---

## Caso de Uso 2: Registro de un nuevo pago de energía eléctrica

**Descripción:** El usuario registra un nuevo pago para un local de energía eléctrica.

**Precondiciones:**
El usuario está autenticado y tiene permisos de captura.

**Pasos a seguir:**
1. El usuario accede a la página de registro de pagos (no incluida en este formulario, pero soportada por el API).
2. Ingresa los datos requeridos: id_energia, año, periodo, fecha_pago, oficina, caja, operación, importe, consumo, cantidad, folio.
3. Envía el formulario.
4. El sistema valida y registra el pago vía API.

**Resultado esperado:**
El pago queda registrado y puede ser consultado posteriormente.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "fecha_pago": "2024-06-10", "oficina_pago": 2, "caja_pago": "A", "operacion_pago": 4567, "importe_pago": 1500.00, "cve_consumo": "F", "cantidad": 100.0, "folio": "FOL123" }

---

## Caso de Uso 3: Eliminación de un pago de energía eléctrica

**Descripción:** El usuario elimina un pago registrado por error.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación.

**Pasos a seguir:**
1. El usuario consulta los pagos de un local.
2. Identifica el pago a eliminar (por id_pago_energia).
3. Solicita la eliminación vía API.

**Resultado esperado:**
El pago es eliminado de la base de datos y ya no aparece en la consulta.

**Datos de prueba:**
{ "id_pago_energia": 789 }

---

