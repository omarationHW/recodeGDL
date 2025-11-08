# Casos de Uso - ConsCapturaEnergia

**Categoría:** Form

## Caso de Uso 1: Consulta de pagos capturados de energía eléctrica para un local

**Descripción:** El usuario desea visualizar todos los pagos de energía eléctrica registrados para un local específico.

**Precondiciones:**
El usuario está autenticado y tiene permisos de consulta. El id_energia es válido.

**Pasos a seguir:**
1. El usuario accede a la página de consulta de pagos de energía eléctrica.
2. El sistema solicita el parámetro id_energia (por ruta o query).
3. El frontend llama a la API con action 'getPagosEnergia' y el id_energia.
4. El backend ejecuta el stored procedure y devuelve la lista de pagos.
5. El frontend muestra la tabla con los pagos.

**Resultado esperado:**
Se muestra una tabla con todos los pagos capturados para el local/contrato seleccionado.

**Datos de prueba:**
{ "id_energia": 123 }

---

## Caso de Uso 2: Eliminación de un pago de energía eléctrica y restauración del adeudo

**Descripción:** El usuario desea eliminar un pago capturado por error y restaurar el adeudo correspondiente.

**Precondiciones:**
El usuario está autenticado y tiene permisos de eliminación. El pago existe.

**Pasos a seguir:**
1. El usuario visualiza la tabla de pagos y selecciona el pago a eliminar.
2. El usuario hace clic en 'Borrar'.
3. El frontend llama a la API con action 'restoreAdeudoEnergia' (si no existe el adeudo).
4. Luego llama a 'deletePagoEnergia' para eliminar el pago.
5. El backend ejecuta ambos stored procedures.
6. El frontend actualiza la tabla.

**Resultado esperado:**
El pago es eliminado y el adeudo es restaurado si no existía. La tabla se actualiza.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "cve_consumo": "F", "cantidad": 100, "importe": 500.00, "usuario_id": 1 }

---

## Caso de Uso 3: Intento de restaurar un adeudo ya existente

**Descripción:** El usuario intenta restaurar un adeudo que ya existe para el periodo dado.

**Precondiciones:**
El adeudo ya existe en la tabla ta_11_adeudo_energ para ese periodo.

**Pasos a seguir:**
1. El usuario intenta borrar un pago.
2. El frontend llama a 'restoreAdeudoEnergia'.
3. El stored procedure detecta que ya existe el adeudo y no lo duplica.
4. El proceso continúa normalmente.

**Resultado esperado:**
El sistema no duplica el adeudo y muestra un mensaje informativo.

**Datos de prueba:**
{ "id_energia": 123, "axo": 2024, "periodo": 6, "cve_consumo": "F", "cantidad": 100, "importe": 500.00, "usuario_id": 1 }

---

