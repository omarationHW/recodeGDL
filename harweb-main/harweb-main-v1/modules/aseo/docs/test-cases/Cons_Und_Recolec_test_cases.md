# Casos de Prueba: Consulta Unidades de Recolección

## Caso 1: Consulta básica por ejercicio
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 2024, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - Código HTTP 200
  - success: true
  - data: array con filas (campos: ctrol_recolec, ejercicio_recolec, cve_recolec, descripcion, costo_unidad, costo_exed)
  - message: ''

## Caso 2: Consulta con orden por descripción
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 2023, order: 'descripcion' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: array ordenada alfabéticamente por descripcion

## Caso 3: Exportar a Excel
- **Entrada:**
  - eRequest: cons_und_recolec_export
  - params: { ejercicio: 2024, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: array con los mismos datos que la consulta
  - El frontend genera y descarga un archivo CSV

## Caso 4: Error por parámetro inválido
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 'abcd', order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: false
  - message: error de tipo/conversión

## Caso 5: Ejercicio sin datos
- **Entrada:**
  - eRequest: cons_und_recolec_list
  - params: { ejercicio: 1999, order: 'ctrol_recolec' }
- **Acción:** POST /api/execute
- **Resultado esperado:**
  - success: true
  - data: []
  - message: ''
