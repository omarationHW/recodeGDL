# Casos de Prueba para IndividualPredios

## Caso 1: Consulta de Convenio Existente
- **Entrada:** id_conv_predio=12345
- **Acción:** getPredioById
- **Resultado esperado:** Se devuelve un objeto con los datos completos del convenio/predio

## Caso 2: Consulta de Adeudos Vencidos
- **Entrada:** id_conv_resto=6789, fecha='2024-06-01'
- **Acción:** getAdeudosByPredio
- **Resultado esperado:** Se devuelve un array de adeudos con los campos pago_parcial, importe, fecha_venc, recargos

## Caso 3: Consulta de Total Pagado
- **Entrada:** id_conv_resto=6789
- **Acción:** getTotPagadoByPredio
- **Resultado esperado:** Se devuelve un array con los pagos realizados (importe_pago, cve_descuento)

## Caso 4: Cálculo de Recargos
- **Entrada:** id_conv_resto=6789, importe=1000.00, fecha_venc='2024-05-01', fecha_actual='2024-06-01'
- **Acción:** getRecargosByAdeudo
- **Resultado esperado:** Se devuelve el recargo calculado según la lógica de negocio

## Caso 5: Día de Vencimiento
- **Entrada:** id_conv_resto=6789, anio=2024, mes=6
- **Acción:** getDiaVencimiento
- **Resultado esperado:** Se devuelve el día de vencimiento correspondiente

## Caso 6: Días Inhábiles
- **Entrada:** fecha='2024-06-01'
- **Acción:** getDiasInhabiles
- **Resultado esperado:** Se devuelve un array con los días inhábiles para la fecha dada

## Caso 7: Error por Falta de Parámetros
- **Entrada:** (sin id_conv_predio)
- **Acción:** getPredioById
- **Resultado esperado:** eResponse.success=false, eResponse.message indica el error
