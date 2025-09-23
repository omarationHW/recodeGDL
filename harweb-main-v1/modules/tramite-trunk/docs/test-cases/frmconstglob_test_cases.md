# Casos de Prueba para frmconstglob (Construcciones Globales)

## Caso 1: Consulta exitosa
- **Entrada:** cvecatnva = 'D6512345678'
- **Acción:** POST /api/execute { eRequest: { operation: 'list', params: { cvecatnva: 'D6512345678' } } }
- **Esperado:** eResponse.success = true, eResponse.data contiene lista de construcciones

## Caso 2: Alta con datos válidos
- **Entrada:**
  - operation: 'create'
  - params: { cvecatnva: 'D6512345678', subpredio: 0, cvebloque: 5, axoconst: 2015, areaconst: 120.5, cveclasif: 2, cvecuenta: 12345, estructura: 1, factorajus: 1.0, numpisos: 2, importe: 250000.00, cveavaluo: 1001, axovig: 2024, vigente: 'V' }
- **Acción:** POST /api/execute
- **Esperado:** eResponse.success = true, eResponse.message = 'Registro creado', eResponse.data.cvebloque = 5

## Caso 3: Eliminación exitosa
- **Entrada:**
  - operation: 'delete'
  - params: { cvebloque: 5 }
- **Acción:** POST /api/execute
- **Esperado:** eResponse.success = true, eResponse.message = 'Registro eliminado'

## Caso 4: Alta con datos incompletos
- **Entrada:** Falta campo obligatorio (ej: cvebloque)
- **Esperado:** eResponse.success = false, eResponse.message indica el campo faltante

## Caso 5: Consulta con clave inexistente
- **Entrada:** cvecatnva = 'D6599999999'
- **Esperado:** eResponse.success = true, eResponse.data = []
