# Casos de Prueba: Padrón Global de Locales

## Caso 1: Consulta básica de locales vigentes
- **Entrada:** { "axo": 2024, "mes": 6, "vig": "A" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array de locales con vigencia 'A'
  - Cada registro incluye cálculo correcto de renta y leyenda

## Caso 2: Exportación a Excel
- **Entrada:** { "axo": 2023, "mes": 12, "vig": "B" }
- **Acción:** POST /api/execute con action=exportPadronGlobalExcel
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data.url: contiene la URL de descarga del archivo Excel

## Caso 3: Consulta de vencimiento de recargos
- **Entrada:** { "mes": 6 }
- **Acción:** POST /api/execute con action=getVencimientoRec
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array con información de vencimiento para el mes 6

## Caso 4: Consulta con filtros inexistentes
- **Entrada:** { "axo": 1900, "mes": 1, "vig": "A" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: true
  - data: array vacío

## Caso 5: Error de parámetros
- **Entrada:** { "axo": "", "mes": "", "vig": "" }
- **Acción:** POST /api/execute con action=getPadronGlobal
- **Resultado esperado:**
  - HTTP 200
  - success: false
  - message: error de parámetros o mensaje descriptivo
