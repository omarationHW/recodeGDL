# Casos de Prueba para RprtListaxRegMer

## Caso 1: Consulta básica por oficina y mercado
- **Entrada:**
  - oficina: 5
  - num_mercado: 1
  - vigencia: "1"
  - clave_practicado: "todas"
- **Acción:** POST /api/execute con eRequest=getRprtListaxRegMer
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con al menos un registro
  - Totales correctos

## Caso 2: Consulta por vigencia pagado o P
- **Entrada:**
  - oficina: 3
  - num_mercado: 2
  - vigencia: "2"
  - clave_practicado: "todas"
- **Acción:** POST /api/execute con eRequest=getRprtListaxRegMer
- **Esperado:**
  - HTTP 200
  - success: true
  - data: registros con vigencia '2' o 'P'

## Caso 3: Consulta por clave_practicado específica
- **Entrada:**
  - oficina: 7
  - num_mercado: 4
  - vigencia: "todas"
  - clave_practicado: "A123"
- **Acción:** POST /api/execute con eRequest=getRprtListaxRegMer
- **Esperado:**
  - HTTP 200
  - success: true
  - data: solo registros con clave_practicado = 'A123'

## Caso 4: Sin resultados
- **Entrada:**
  - oficina: 99
  - num_mercado: 99
  - vigencia: "1"
  - clave_practicado: "todas"
- **Acción:** POST /api/execute con eRequest=getRprtListaxRegMer
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array vacío

## Caso 5: Error de parámetros
- **Entrada:**
  - oficina: null
  - num_mercado: null
- **Acción:** POST /api/execute con eRequest=getRprtListaxRegMer
- **Esperado:**
  - HTTP 200
  - success: false
  - message: error de parámetros o validación

## Caso 6: Consulta de recaudadora y zona
- **Entrada:**
  - oficina: 5
- **Acción:** POST /api/execute con eRequest=getRecaudadoraZona
- **Esperado:**
  - HTTP 200
  - success: true
  - data: array con datos de recaudadora y zona
