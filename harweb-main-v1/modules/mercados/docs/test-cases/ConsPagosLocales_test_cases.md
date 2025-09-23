# Casos de Prueba: Consulta de Pagos del Local

## Caso 1: Consulta exitosa por local
- **Entrada:**
  - oficina: 1
  - num_mercado: 10
  - categoria: 2
  - seccion: 'A'
  - local: 5
  - letra_local: 'B'
  - bloque: 'C'
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: true
  - data: lista de pagos con los campos correctos
  - message: ''

## Caso 2: Consulta exitosa por fecha
- **Entrada:**
  - fecha_pago: '2024-06-01'
  - oficina_pago: 2
  - caja_pago: 'A'
  - operacion_pago: 12345
- **Acción:** buscarPagosPorFecha
- **Resultado esperado:**
  - success: true
  - data: lista de pagos con los campos correctos
  - message: ''

## Caso 3: Filtros incompletos
- **Entrada:**
  - (ningún filtro)
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: false
  - data: null
  - message: 'Seleccione una opción de búsqueda.'

## Caso 4: Error en stored procedure
- **Entrada:**
  - oficina: 'ZZZ' (valor inválido)
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: false
  - data: null
  - message: error de base de datos

## Caso 5: Consulta sin resultados
- **Entrada:**
  - oficina: 99
  - num_mercado: 99
  - categoria: 9
  - seccion: 'Z'
  - local: 9999
- **Acción:** buscarPagosPorLocal
- **Resultado esperado:**
  - success: true
  - data: []
  - message: ''
