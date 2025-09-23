# Casos de Prueba: Reporte de Adeudos Condonados

## Caso 1: Consulta exitosa por periodo de pago
- **Entrada:**
  - control_contrato: 1228
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array con registros ordenados por aso_mes_pago, cve_operacion
  - error=null

## Caso 2: Consulta exitosa por operación
- **Entrada:**
  - control_contrato: 1228
  - opcion: 2
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array con registros ordenados por cve_operacion, aso_mes_pago
  - error=null

## Caso 3: Consulta sin resultados
- **Entrada:**
  - control_contrato: 9999 (contrato inexistente o sin adeudos condonados)
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=true
  - data: array vacío
  - error=null

## Caso 4: Parámetro faltante
- **Entrada:**
  - control_contrato: (no enviado)
  - opcion: 1
- **Acción:**
  - POST /api/execute con eRequest=getAdeudosCondonados y los parámetros anteriores
- **Resultado esperado:**
  - success=false
  - data: null
  - error: 'control_contrato es requerido'

## Caso 5: eRequest no soportado
- **Entrada:**
  - eRequest: 'unknownRequest'
- **Acción:**
  - POST /api/execute con eRequest=unknownRequest
- **Resultado esperado:**
  - success=false
  - data: null
  - error: 'eRequest no soportado'
