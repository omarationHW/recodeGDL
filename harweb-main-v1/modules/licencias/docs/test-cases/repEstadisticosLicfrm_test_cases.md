# Casos de Prueba para repEstadisticosLicfrm

## Caso 1: Reporte de licencias dadas de alta en un rango de fechas
- **Entrada:**
  - action: reporte_licencias_rango
  - params: { fecha1: '2024-01-01', fecha2: '2024-06-30' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data es un array con campos: id_giro, descripcion, z_1, ..., total

## Caso 2: Reporte de giros reglamentados por zona (solo tipo D)
- **Entrada:**
  - action: reporte_giros_reglamentados_zona
  - params: { clasificacion: 'D' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data contiene solo giros tipo D

## Caso 3: Reporte de pagos de licencias en un rango de fechas
- **Entrada:**
  - action: reporte_pagos_licencias_rango
  - params: { fecha1: '2024-01-01', fecha2: '2024-06-30' }
- **Esperado:**
  - HTTP 200, eResponse.success = true
  - eResponse.data contiene campos: recaud, cuantos

## Caso 4: Validación de fechas requeridas
- **Entrada:**
  - action: reporte_licencias_rango
  - params: { fecha1: '', fecha2: '' }
- **Esperado:**
  - HTTP 400, eResponse.success = false
  - eResponse.error indica que las fechas son requeridas

## Caso 5: Acción no soportada
- **Entrada:**
  - action: reporte_no_existente
  - params: {}
- **Esperado:**
  - HTTP 400, eResponse.success = false
  - eResponse.error = 'Acción no soportada'
