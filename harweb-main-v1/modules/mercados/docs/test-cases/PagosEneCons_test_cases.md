# Casos de Prueba para PagosEneCons

## Caso 1: Consulta de pagos de energía eléctrica
- **Entrada:** id_energia = 123
- **Acción:** POST /api/execute { action: 'getPagosEnergia', params: { id_energia: 123 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: Array de pagos con campos correctos

## Caso 2: Registro de un nuevo pago
- **Entrada:**
  - id_energia: 123
  - axo: 2024
  - periodo: 6
  - fecha_pago: '2024-06-10'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 4567
  - importe_pago: 1500.00
  - cve_consumo: 'F'
  - cantidad: 100.0
  - folio: 'FOL123'
- **Acción:** POST /api/execute { action: 'addPagoEnergia', params: { ... } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: registro insertado

## Caso 3: Eliminación de un pago
- **Entrada:** id_pago_energia = 789
- **Acción:** POST /api/execute { action: 'deletePagoEnergia', params: { id_pago_energia: 789 } }
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: [{ deleted: true }]

## Caso 4: Error por falta de parámetro obligatorio
- **Entrada:** POST /api/execute { action: 'getPagosEnergia', params: { } }
- **Resultado esperado:**
  - HTTP 422
  - success: false
  - message: 'Parámetro id_energia requerido.'

## Caso 5: Error por acción no soportada
- **Entrada:** POST /api/execute { action: 'unknownAction', params: { } }
- **Resultado esperado:**
  - HTTP 400
  - success: false
  - message: 'Acción no soportada.'
