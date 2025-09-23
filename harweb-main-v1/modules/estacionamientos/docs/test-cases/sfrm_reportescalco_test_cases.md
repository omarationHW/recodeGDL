# Casos de Prueba para Reportes de Calcomanías

## Caso 1: Reporte de calcomanías expedidas (con datos)
- **Entrada:**
  - eRequest: get_calcomania_report
  - params: { "fecha1": "2024-01-01", "fecha2": "2024-01-31" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con campos: placa, num_calco, fecha_inicial, fecha_fin, propietario, etc.

## Caso 2: Reporte de folios capturados (con datos)
- **Entrada:**
  - eRequest: get_folios_report
  - params: { "fechora": "2024-02-15" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con campos: inspector, folios

## Caso 3: Reporte de calcomanías expedidas (sin datos)
- **Entrada:**
  - eRequest: get_calcomania_report
  - params: { "fecha1": "1990-01-01", "fecha2": "1990-01-02" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío

## Caso 4: Reporte de folios capturados (sin datos)
- **Entrada:**
  - eRequest: get_folios_report
  - params: { "fechora": "1990-01-01" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un arreglo vacío

## Caso 5: Error por eRequest inválido
- **Entrada:**
  - eRequest: "unknown_request"
  - params: { }
- **Esperado:**
  - eResponse.success = false
  - eResponse.error contiene mensaje de error

## Caso 6: Validación de formato de fechas
- **Entrada:**
  - eRequest: get_calcomania_report
  - params: { "fecha1": "2024-13-01", "fecha2": "2024-01-31" }
- **Esperado:**
  - eResponse.success = false
  - eResponse.error indica error de formato de fecha
