# Casos de Prueba para RptAdeudoCorteManzanaSaldoAnt

## Caso 1: Consulta exitosa del reporte
- **Entrada:**
  - subtipo: 1
  - fechadsd: '2024-01-01'
  - fechahst: '2024-06-30'
  - rep: 2
  - est: 'A'
- **Acción:** POST /api/execute con eRequest.action = 'getReportData'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un registro
  - Cada registro contiene los campos: manzana, lote, letracomp, nombre, calle, num_exterior, num_interior, inciso, cantidad_total, parcpag, pagos, recargos, SaldoAnterior

## Caso 2: Parámetro faltante (fecha desde)
- **Entrada:**
  - subtipo: 1
  - fechadsd: ''
  - fechahst: '2024-06-30'
  - rep: 2
  - est: 'A'
- **Acción:** POST /api/execute con eRequest.action = 'getReportData'
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'fechadsd'

## Caso 3: Consulta de subtipos
- **Entrada:**
  - tipo: 14
- **Acción:** POST /api/execute con eRequest.action = 'getSubtipos'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con campos subtipo y desc_subtipo

## Caso 4: Consulta de saldo anterior
- **Entrada:**
  - subtipo: 1
  - id_conv_predio: 123
  - fechadsd: '2024-01-01'
- **Acción:** POST /api/execute con eRequest.action = 'getSaldoAnterior'
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con campos id_conv_predio, tipo, cantidad_total, pagos

## Caso 5: Seguridad (no autenticado)
- **Entrada:**
  - Cualquier acción
- **Acción:** POST /api/execute sin token de autenticación
- **Esperado:**
  - HTTP 401 Unauthorized

## Caso 6: SQL Injection
- **Entrada:**
  - subtipo: "1; DROP TABLE ta_17_con_reg_pred; --"
- **Acción:** POST /api/execute con eRequest.action = 'getReportData'
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message indica error de validación
