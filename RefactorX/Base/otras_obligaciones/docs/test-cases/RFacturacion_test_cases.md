# Casos de Prueba para RFacturacion

## Caso 1: Consulta periodo actual, adeudos y pagos, sin recargos
- **Entrada:**
  - adeudo_status: 'A'
  - adeudo_recargo: 'N'
  - year: año actual
  - month: mes actual
  - periodo_actual: true
- **Acción:** POST /api/execute con eRequest correspondiente
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene registros
  - El total de la tabla corresponde a la suma de los importes

## Caso 2: Consulta solo adeudos con recargos, periodo anterior
- **Entrada:**
  - adeudo_status: 'B'
  - adeudo_recargo: 'S'
  - year: 2023
  - month: 3
  - periodo_actual: false
- **Acción:** POST /api/execute con eRequest correspondiente
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene solo adeudos con recargo
  - El total corresponde a la suma de los importes

## Caso 3: Consulta solo pagados, periodo específico
- **Entrada:**
  - adeudo_status: 'C'
  - adeudo_recargo: 'N'
  - year: 2022
  - month: 12
  - periodo_actual: false
- **Acción:** POST /api/execute con eRequest correspondiente
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene solo registros pagados
  - El total corresponde a la suma de los importes

## Caso 4: Error por falta de año/mes en periodo anterior
- **Entrada:**
  - periodo_actual: false
  - year: ''
  - month: ''
- **Acción:** Intentar consultar
- **Esperado:**
  - En frontend, error: 'Falta el dato del AÑO o MES a consultar, intentalo de nuevo'

## Caso 5: Acción no soportada
- **Entrada:**
  - eRequest.action: 'accionInexistente'
- **Acción:** POST /api/execute
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'Acción no soportada'
