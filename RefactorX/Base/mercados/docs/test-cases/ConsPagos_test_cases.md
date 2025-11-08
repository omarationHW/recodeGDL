# Casos de Prueba: Consulta de Pagos (ConsPagos)

## Caso 1: Consulta de pagos de un local existente
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getPagosByLocal', params: { id_local: 12345 } }
- **Resultado esperado:** Respuesta success=true, data contiene lista de pagos, cada uno con campos completos.

## Caso 2: Consulta de pagos de un local inexistente
- **Entrada:** id_local = 999999
- **Acción:** POST /api/execute { action: 'getPagosByLocal', params: { id_local: 999999 } }
- **Resultado esperado:** Respuesta success=true, data=[], mensaje vacío o informativo.

## Caso 3: Agregar un pago válido
- **Entrada:**
  - id_local: 12345
  - axo: 2024
  - periodo: 6
  - fecha_pago: '2024-06-15'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 1001
  - importe_pago: 1500.00
  - folio: 'F1234'
  - id_usuario: 1
- **Acción:** POST /api/execute { action: 'addPago', params: {...} }
- **Resultado esperado:** success=true, data contiene id_pago_local generado.

## Caso 4: Agregar un pago con datos faltantes
- **Entrada:** Falta campo 'importe_pago'
- **Acción:** POST /api/execute { action: 'addPago', params: {...} }
- **Resultado esperado:** success=false, message indica campo requerido.

## Caso 5: Eliminar un pago existente
- **Entrada:** id_pago_local = 98765
- **Acción:** POST /api/execute { action: 'deletePago', params: { id_pago_local: 98765 } }
- **Resultado esperado:** success=true, data=true

## Caso 6: Eliminar un pago inexistente
- **Entrada:** id_pago_local = 999999
- **Acción:** POST /api/execute { action: 'deletePago', params: { id_pago_local: 999999 } }
- **Resultado esperado:** success=true, data=true (o success=false si se requiere validación estricta)
