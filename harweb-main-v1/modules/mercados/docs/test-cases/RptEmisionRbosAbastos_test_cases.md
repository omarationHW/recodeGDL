# Casos de Prueba: RptEmisionRbosAbastos

## Caso 1: Consulta exitosa de reporte
- **Entrada:** { action: 'getReportData', params: { oficina: 5, mercado: 1, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta con success=true, data es un array de locales con campos calculados, sin error.

## Caso 2: Consulta de requerimientos de local
- **Entrada:** { action: 'getRequerimientos', params: { id_local: 12345 } }
- **Esperado:** Respuesta con success=true, data es un array de requerimientos, sin error.

## Caso 3: Consulta de recargos del mes
- **Entrada:** { action: 'getRecargosMes', params: { axo: 2024, mes: 6 } }
- **Esperado:** Respuesta con success=true, data es un array con los recargos del mes.

## Caso 4: Parámetros insuficientes
- **Entrada:** { action: 'getReportData', params: { oficina: 5, mercado: 1 } }
- **Esperado:** success=false, message indica parámetros insuficientes.

## Caso 5: Acción no soportada
- **Entrada:** { action: 'accionInexistente', params: {} }
- **Esperado:** success=false, message indica acción no soportada.
