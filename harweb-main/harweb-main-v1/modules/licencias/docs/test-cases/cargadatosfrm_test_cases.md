# Casos de Prueba para Formulario cargadatosfrm

## Caso 1: Consulta exitosa de datos catastrales
- **Entrada:** cvecatnva = 'D65J1345001'
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: 'D65J1345001' } }
- **Resultado esperado:** success=true, data contiene ubicación, propietario, domicilio, etc.

## Caso 2: Consulta de avalúos y construcciones
- **Entrada:** cvecatnva = 'D65J1345001', subpredio = 0
- **Acción:** POST /api/execute { action: 'getAvaluos', params: { cvecatnva: 'D65J1345001', subpredio: 0 } }
- **Resultado esperado:** success=true, data es lista de avalúos
- **Acción secundaria:** POST /api/execute { action: 'getConstrucciones', params: { cveavaluo: <id> } }
- **Resultado esperado:** success=true, data es lista de construcciones

## Caso 3: Error por clave catastral inexistente
- **Entrada:** cvecatnva = 'XXXXXX'
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: 'XXXXXX' } }
- **Resultado esperado:** success=false, message='No se encontró la clave catastral'

## Caso 4: Actualización exitosa de datos
- **Entrada:** cvecatnva = 'D65J1345001', nombre_completo = 'Juan Pérez', rfc = 'PEPJ800101XXX'
- **Acción:** POST /api/execute { action: 'saveCargadatos', params: { cvecatnva: 'D65J1345001', nombre_completo: 'Juan Pérez', rfc: 'PEPJ800101XXX' } }
- **Resultado esperado:** success=true, data.updated=true

## Caso 5: Error por falta de parámetro obligatorio
- **Entrada:** cvecatnva = ''
- **Acción:** POST /api/execute { action: 'getCargadatos', params: { cvecatnva: '' } }
- **Resultado esperado:** success=false, message='Falta parámetro cvecatnva'
