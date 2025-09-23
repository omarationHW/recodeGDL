# Casos de Prueba para Firmas

## 1. Alta de Firma Exitosa
- **Entrada:** Todos los campos válidos, recaudadora no existente
- **Acción:** POST /api/execute { action: 'create', entity: 'firmas', data: { ... } }
- **Resultado esperado:** status: success, message: 'Firma creada correctamente', la firma aparece en el listado

## 2. Alta de Firma con recaudadora duplicada
- **Entrada:** recaudadora ya existente
- **Acción:** POST /api/execute { action: 'create', entity: 'firmas', data: { ... } }
- **Resultado esperado:** status: error, message: 'duplicate key value violates unique constraint', no se crea la firma

## 3. Edición de Firma Exitosa
- **Entrada:** recaudadora existente, campos modificados válidos
- **Acción:** POST /api/execute { action: 'update', entity: 'firmas', data: { ... } }
- **Resultado esperado:** status: success, message: 'Firma actualizada correctamente', cambios reflejados en el listado

## 4. Eliminación de Firma Exitosa
- **Entrada:** recaudadora existente
- **Acción:** POST /api/execute { action: 'delete', entity: 'firmas', data: { recaudadora: 2 } }
- **Resultado esperado:** status: success, message: 'Firma eliminada correctamente', firma ya no aparece en el listado

## 5. Consulta de Firma Específica
- **Entrada:** recaudadora existente
- **Acción:** POST /api/execute { action: 'get', entity: 'firmas', data: { recaudadora: 2 } }
- **Resultado esperado:** status: success, data: [ ... ], message: 'Firma obtenida correctamente'

## 6. Validación de Campos Vacíos
- **Entrada:** Falta campo obligatorio (ej. titular vacío)
- **Acción:** POST /api/execute { action: 'create', entity: 'firmas', data: { ... } }
- **Resultado esperado:** status: error, message: 'The titular field is required.'

## 7. Listado General
- **Entrada:**
- **Acción:** POST /api/execute { action: 'list', entity: 'firmas' }
- **Resultado esperado:** status: success, data: [ ... ], message: 'Listado obtenido correctamente'
