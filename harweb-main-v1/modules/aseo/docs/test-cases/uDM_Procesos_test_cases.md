# Casos de Prueba para Procesos de Aseo

## Caso 1: Consulta de Tipos de Aseo
- **Input:**
  - operation: get_tipo_aseo
  - params: { tipo: 0 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data contiene lista de tipos de aseo (sin ctrol_aseo=0)

## Caso 2: Consulta de Día Límite
- **Input:**
  - operation: get_dia_limite
  - params: { mes: 6 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].dia = valor esperado según tabla

## Caso 3: Consulta de Contratos Totales
- **Input:**
  - operation: get_contratos_count
  - params: { ctrol: 1 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros = número esperado

## Caso 4: Consulta de Contratos por Status
- **Input:**
  - operation: get_contratos_count
  - params: { ctrol: 1, status: 'V' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros = número esperado de vigentes

## Caso 5: Resumen de Pagos por Operación
- **Input:**
  - operation: get_pagos_summary
  - params: { ctrol_a: 1, fecha: '2024-06', operacion: 6, status: 'V' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0].registros y .importe correctos

## Caso 6: Dashboard de Procesos
- **Input:**
  - operation: procesos_dashboard
  - params: { ctrol_a: 1, fecha1: '2024-06', fecha2: '2024-04' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data[0] contiene contratos_total, contratos_vigentes, contratos_cancelados y pagos (array)

## Caso 7: Operación No Soportada
- **Input:**
  - operation: unknown_operation
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message = 'Operación no soportada'
