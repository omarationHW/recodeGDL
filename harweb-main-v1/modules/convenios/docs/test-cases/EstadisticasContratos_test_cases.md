# Casos de Prueba para Estadísticas Contratos

## Caso 1: Consulta de Estadísticas de Contratos
- **Entrada:**
  - action: getEstadisticasContratos
  - params: { anio_obra: 2023, fondo: 16 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con columnas: colonia, calle, folio, nombre, numero, costo, pagos, saldo

## Caso 2: Consulta de Adeudos Vencidos
- **Entrada:**
  - action: getAdeudosVencidos
  - params: { anio_obra: 2022, fondo: 15 }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con columnas: colonia, calle, folio, nombre, numero, costo, pagos, saldo, importe_vencido, etc.

## Caso 3: Consulta de Recaudación por Fechas
- **Entrada:**
  - action: getRecaudacion
  - params: { fecha_desde: '2024-01-01', fecha_hasta: '2024-01-31', clasificacion: 'cuenta_ing' }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con columnas: fecha_pago, oficina_pago, caja_pago, importe, clasificacion

## Caso 4: Consulta de Estadísticas por Periodo
- **Entrada:**
  - action: getEstadisticasPeriodos
  - params: { anio_obra: 2021, adeudo_min: 5000, detalle: true }
- **Esperado:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con columnas: plazo, cve_plazo, axo_obra, axo_firma, saldo_real, desc_plazo, etc.

## Caso 5: Validación de Parámetros Faltantes
- **Entrada:**
  - action: getEstadisticasContratos
  - params: { }
- **Esperado:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.message indica error de parámetros
