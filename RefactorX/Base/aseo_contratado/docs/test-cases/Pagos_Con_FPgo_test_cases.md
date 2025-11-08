# Casos de Prueba: Pagos_Con_FPgo

## Caso 1: Consulta de pagos por fecha válida
- **Entrada:** fecha = '2024-06-01'
- **Acción:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { fecha: '2024-06-01' } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data contiene lista de pagos, cada pago tiene control_contrato, aso_mes_pago, descripcion, importe, etc.

## Caso 2: Consulta de pagos por fecha sin resultados
- **Entrada:** fecha = '2023-01-01'
- **Acción:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { fecha: '2023-01-01' } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data = []

## Caso 3: Consulta de detalle de contrato existente
- **Entrada:** control_contrato = 1803
- **Acción:** POST /api/execute { eRequest: { action: 'getContratoDetalle', params: { control_contrato: 1803 } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data[0] contiene los campos del contrato (num_contrato, tipo_aseo, descripcion, cantidad_recolec, aso_mes_oblig, etc.)

## Caso 4: Consulta de detalle de contrato inexistente
- **Entrada:** control_contrato = 999999
- **Acción:** POST /api/execute { eRequest: { action: 'getContratoDetalle', params: { control_contrato: 999999 } } }
- **Resultado esperado:** eResponse.success = true, eResponse.data = []

## Caso 5: Error de parámetros
- **Entrada:** POST /api/execute { eRequest: { action: 'getPagosByFecha', params: { } } }
- **Resultado esperado:** eResponse.success = false, eResponse.message contiene 'Fecha requerida'
