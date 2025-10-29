# Casos de Prueba: Padrón de Contratos

## Caso 1: Consulta de contratos vigentes ordinarios
- **Entrada:**
  - tipo: 'O'
  - vigencia: 'V'
- **Acción:** POST /api/execute { action: 'getPadronContratos', params: { tipo: 'O', vigencia: 'V' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array de contratos con tipo_aseo = 'O' y status_vigencia = 'V'

## Caso 2: Detalle de adeudos de contrato
- **Entrada:**
  - control: 12345
  - rep: 'V'
  - fecha: '2024-06'
- **Acción:** POST /api/execute { action: 'getDetalleAdeudos', params: { control: 12345, rep: 'V', fecha: '2024-06' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array con campos concepto, importe_adeudos, importe_recargos, importe_multa, importe_gastos

## Caso 3: Consulta de contratos por periodo personalizado
- **Entrada:**
  - tipo: 'T'
  - vigencia: 'T'
  - anio: '2023'
  - mes: '03'
- **Acción:** POST /api/execute { action: 'getPadronContratos', params: { tipo: 'T', vigencia: 'T', anio: '2023', mes: '03' } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array de contratos activos en marzo 2023

## Caso 4: Error por falta de parámetros
- **Entrada:**
  - action: 'getDetalleAdeudos', params: { control: null, fecha: null }
- **Esperado:**
  - HTTP 200
  - success: false
  - message: 'Parámetros requeridos: control, fecha'

## Caso 5: Día límite del mes
- **Entrada:**
  - mes: 6
- **Acción:** POST /api/execute { action: 'getDiaLimite', params: { mes: 6 } }
- **Esperado:**
  - HTTP 200
  - success: true
  - data: Array con campos mes, dia
