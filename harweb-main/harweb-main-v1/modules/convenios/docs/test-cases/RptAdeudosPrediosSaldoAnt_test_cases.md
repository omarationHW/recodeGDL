# Casos de Prueba para RptAdeudosPrediosSaldoAnt

## Caso 1: Consulta exitosa de reporte
- **Entrada:**
  - subtipo: 1
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - est: 'A'
- **Acción:** POST /api/execute { eRequest: { action: 'getReport', params: { ... } } }
- **Resultado esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con campos: id_conv_predio, manzana, lote, letracomp, nombre, saldoanterior, pagos, recargos, etc.

## Caso 2: Validación de parámetros requeridos
- **Entrada:**
  - subtipo: (vacío)
  - fechadsd: 2024-01-01
  - fechahst: 2024-06-30
  - est: 'A'
- **Acción:** POST /api/execute { eRequest: { action: 'getReport', params: { ... } } }
- **Resultado esperado:**
  - Código 200/400
  - eResponse.success = false
  - eResponse.message indica el error de validación

## Caso 3: Consulta de subtipos
- **Entrada:**
  - tipo: 14
- **Acción:** POST /api/execute { eRequest: { action: 'getSubtipos', params: { tipo: 14 } } }
- **Resultado esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array de subtipos

## Caso 4: Consulta de saldo anterior
- **Entrada:**
  - subtipo: 1
  - id_conv_predio: 1234
  - fechadsd: 2024-01-01
- **Acción:** POST /api/execute { eRequest: { action: 'getSaldoAnterior', params: { ... } } }
- **Resultado esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data contiene los campos id_conv_predio, cantidad_total, pagos

## Caso 5: Error de stored procedure
- **Simulación:** Forzar error en la base de datos
- **Resultado esperado:**
  - Código 500
  - eResponse.success = false
  - eResponse.message contiene el mensaje de error
