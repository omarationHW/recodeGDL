# Casos de Prueba para ImpOficiofrm

## Caso 1: Registro exitoso de oficio
- **Entrada:**
  - tramite_id: 123
  - oficio_type: 2
  - usuario_id: 45
  - observaciones: "Observación de prueba"
- **Acción:** POST /api/execute con action=registerOficioDecision
- **Resultado esperado:**
  - success: true
  - data: [{ result: 'Oficio registrado: Dos' }]
  - message: 'Decisión registrada correctamente.'
  - El registro aparece en imp_oficio_bitacora

## Caso 2: Tipo de oficio inválido
- **Entrada:**
  - tramite_id: 123
  - oficio_type: 99
  - usuario_id: 45
- **Acción:** POST /api/execute con action=registerOficioDecision
- **Resultado esperado:**
  - success: false
  - message: 'Tipo de oficio inválido'

## Caso 3: Consulta de opciones de oficio
- **Acción:** POST /api/execute con action=getOficioOptions
- **Resultado esperado:**
  - success: true
  - data: [ { id: 1, label: 'Uno' }, ... ]

## Caso 4: Consulta de trámite inexistente
- **Entrada:**
  - tramite_id: 999999
- **Acción:** POST /api/execute con action=getTramiteInfo
- **Resultado esperado:**
  - success: true
  - data: []

## Caso 5: Cancelación desde frontend
- **Acción:** Usuario hace clic en 'Cancelar'
- **Resultado esperado:**
  - Redirección a /tramites
