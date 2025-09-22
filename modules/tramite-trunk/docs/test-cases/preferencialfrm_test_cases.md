# Casos de Prueba para Formulario Preferencial

## Caso 1: Agregar tasa preferencial válida
- **Entrada**: folio=12345, tasa_nva=0.002, observacion="Autorizada", axoefec=2024, user="admin"
- **Acción**: POST /api/execute { action: 'addPreferencial', payload: {...} }
- **Esperado**: Respuesta success=true, mensaje de éxito, registro aparece en la lista.

## Caso 2: Editar tasa preferencial existente
- **Entrada**: id=10, tasa_nva=0.0018, observacion="Actualización", user="admin"
- **Acción**: POST /api/execute { action: 'updatePreferencial', payload: {...} }
- **Esperado**: Respuesta success=true, mensaje de éxito, registro actualizado.

## Caso 3: Dar de baja tasa preferencial
- **Entrada**: id=10, user_baja="admin"
- **Acción**: POST /api/execute { action: 'bajaPreferencial', payload: {...} }
- **Esperado**: Respuesta success=true, mensaje de éxito, registro marcado como dado de baja.

## Caso 4: Consultar tasas preferenciales por folio
- **Entrada**: folio=12345
- **Acción**: POST /api/execute { action: 'getPreferencialList', payload: { folio: 12345 } }
- **Esperado**: Respuesta success=true, data contiene lista de tasas preferenciales del folio.

## Caso 5: Validar tasas válidas por año
- **Entrada**: axoefec=2024
- **Acción**: POST /api/execute { action: 'getTasasValidas', payload: { axoefec: 2024 } }
- **Esperado**: Respuesta success=true, data contiene lista de tasas válidas para el año.

## Caso 6: Error por parámetros faltantes
- **Entrada**: POST /api/execute { action: 'addPreferencial', payload: { folio: null } }
- **Esperado**: Respuesta success=false, message indica error de validación.
