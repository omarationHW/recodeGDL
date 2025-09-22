# Casos de Prueba para RptPagosContabilidad

## Caso 1: Consulta exitosa de reporte
- **Entrada:**
  - fecdesde: 2024-01-01
  - fechasta: 2024-06-30
- **Acción:** POST /api/execute con action 'getRptPagosContabilidad'
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un arreglo con al menos un registro
  - Cada registro contiene: tipo, axo_obra, cuenta_ingreso, ingreso, descripcion

## Caso 2: Fechas inválidas (fecha final < fecha inicial)
- **Entrada:**
  - fecdesde: 2024-07-01
  - fechasta: 2024-06-30
- **Acción:** POST /api/execute con action 'getRptPagosContabilidad'
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'fechas inválidas' o mensaje de error

## Caso 3: Consulta de catálogo de tipos
- **Entrada:**
  - action: 'getTipos'
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un arreglo con campos tipo y descripcion

## Caso 4: Acción no soportada
- **Entrada:**
  - action: 'unknownAction'
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message contiene 'Acción no soportada'

## Caso 5: Sin datos en el rango
- **Entrada:**
  - fecdesde: 1990-01-01
  - fechasta: 1990-01-31
- **Acción:** POST /api/execute con action 'getRptPagosContabilidad'
- **Resultado esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un arreglo vacío
