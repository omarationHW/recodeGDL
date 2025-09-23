# Casos de Prueba para RptRecup_Merc

## Caso 1: Consulta de reporte con rango de folios válido
- **Entrada:**
  - ofna: 2
  - folio1: 100
  - folio2: 105
- **Acción:**
  - POST /api/execute con eRequest: 'RptRecup_Merc.getReport' y params anteriores
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene al menos un registro con folio entre 100 y 105

## Caso 2: Consulta de reporte con rango de folios sin resultados
- **Entrada:**
  - ofna: 2
  - folio1: 9999
  - folio2: 10000
- **Acción:**
  - POST /api/execute con eRequest: 'RptRecup_Merc.getReport' y params anteriores
- **Esperado:**
  - eResponse.success = true
  - eResponse.data es un array vacío

## Caso 3: Consulta de recaudadora existente
- **Entrada:**
  - reca: 2
- **Acción:**
  - POST /api/execute con eRequest: 'RptRecup_Merc.getRecaudadora' y params anteriores
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene los campos de recaudadora y zona

## Caso 4: Conversión de fecha a letras
- **Entrada:**
  - fecha: '2024-06-05'
- **Acción:**
  - POST /api/execute con eRequest: 'RptRecup_Merc.fechaAletras' y params anteriores
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = '5 de Junio de 2024'

## Caso 5: Parámetros faltantes
- **Entrada:**
  - ofna: null
  - folio1: 100
  - folio2: 105
- **Acción:**
  - POST /api/execute con eRequest: 'RptRecup_Merc.getReport' y params anteriores
- **Esperado:**
  - eResponse.success = false
  - eResponse.message indica parámetro faltante
