# Casos de Prueba: Contratos con Adeudos

## Caso 1: Consulta básica de contratos con adeudos vencidos
- **Entrada:**
  - parTipo: 'O'
  - parVigencia: 'V'
  - parReporte: 'V'
  - pref: '2024-06'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de contratos con campos completos

## Caso 2: Consulta por periodo específico
- **Entrada:**
  - parTipo: 'H'
  - parVigencia: 'N'
  - parReporte: 'T'
  - pref: '2023-03'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de contratos filtrados por periodo

## Caso 3: Exportar a Excel
- **Entrada:**
  - Mismos parámetros que una consulta
- **Acción:** POST /api/execute con action=export_excel
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: archivo Excel o URL de descarga

## Caso 4: Parámetros inválidos
- **Entrada:**
  - parTipo: 'X'
  - parVigencia: 'Z'
  - parReporte: 'Q'
  - pref: 'abcd-ef'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: 'Error al consultar.' o mensaje de validación

## Caso 5: Sin resultados
- **Entrada:**
  - parTipo: 'O'
  - parVigencia: 'C'
  - parReporte: 'T'
  - pref: '1990-01'
- **Acción:** POST /api/execute con action=get_contratos_adeudos
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: []
