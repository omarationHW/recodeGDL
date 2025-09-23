# Casos de Prueba: RptPagosDesarrollo

## 1. Consulta exitosa de reporte
- **Entrada:**
  - fecdesde: 2023-01-01
  - fechasta: 2023-12-31
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con al menos un registro
  - Cada registro contiene: tipo, axo_obra, ingreso, descripcion

## 2. Validación de fechas requeridas
- **Entrada:**
  - fecdesde: (vacío)
  - fechasta: 2023-12-31
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - Código HTTP 200
  - eResponse.success = false
  - eResponse.message indica que los parámetros son requeridos

## 3. Rango sin resultados
- **Entrada:**
  - fecdesde: 2025-01-01
  - fechasta: 2025-01-31
- **Acción:** POST /api/execute con action=getReport
- **Resultado esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - eResponse.data es un array vacío
  - El frontend muestra mensaje de 'No hay datos para el rango seleccionado.'

## 4. Consulta de catálogo de fondos
- **Entrada:**
  - action: getFondos
- **Acción:** POST /api/execute con action=getFondos
- **Resultado esperado:**
  - Código HTTP 200
  - eResponse.success = true
  - eResponse.data es un array de fondos (tipo, descripcion)

## 5. Seguridad: método no soportado
- **Entrada:**
  - action: unknownAction
- **Acción:** POST /api/execute con action=unknownAction
- **Resultado esperado:**
  - Código HTTP 200
  - eResponse.success = false
  - eResponse.message indica 'Acción no soportada.'
