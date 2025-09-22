# Casos de Prueba para Consulta Individual

## Caso 1: Consulta de Folio Existente
- **Entrada:** folio=12345
- **Acción:** getFolio
- **Esperado:**
  - success=true
  - data contiene los campos principales del folio
  - No hay error

## Caso 2: Consulta de Folio Inexistente
- **Entrada:** folio=999999
- **Acción:** getFolio
- **Esperado:**
  - success=false
  - message='Folio no encontrado'

## Caso 3: Consulta de Historia
- **Entrada:** id_control=123
- **Acción:** getFolioHistory
- **Esperado:**
  - success=true
  - data es un array de movimientos

## Caso 4: Consulta de Periodos
- **Entrada:** id_control=123
- **Acción:** getFolioPeriods
- **Esperado:**
  - success=true
  - data es un array de periodos

## Caso 5: Consulta de Detalle de Aplicación
- **Entrada:** modulo=16, control_otr=456
- **Acción:** getModuleDetails
- **Esperado:**
  - success=true
  - data contiene el detalle del contrato de aseo
