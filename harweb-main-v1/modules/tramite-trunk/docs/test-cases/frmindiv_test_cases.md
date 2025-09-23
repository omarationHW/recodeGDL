## Casos de Prueba para frmindiv (Construcciones Individuales)

### Caso 1: Consulta exitosa
- **Input:** cvecatnva = 'D651J100001'
- **Acción:** POST /api/execute { action: 'list', params: { cvecatnva: 'D651J100001' } }
- **Resultado esperado:** 200 OK, data = array de construcciones, success = true

### Caso 2: Alta con datos válidos
- **Input:**
  - cvecatnva: 'D651J100001'
  - subpredio: 2
  - cvebloque: 1
  - axoconst: 2005
  - areaconst: 120.5
  - cveclasif: 3
  - cvecuenta: 12345
- **Acción:** POST /api/execute { action: 'create', params: { ... }
- **Resultado esperado:** 200 OK, data = objeto creado, success = true

### Caso 3: Alta con clave catastral incompleta
- **Input:** cvecatnva = 'D651J10', subpredio = 1, ...
- **Acción:** POST /api/execute { action: 'create', params: { ... } }
- **Resultado esperado:** 400, success = false, message = 'Debe ingresar la clave catastral completa (11 dígitos)'

### Caso 4: Edición de construcción
- **Input:** id = 10, cvecatnva = 'D651J100001', subpredio = 2, ...
- **Acción:** POST /api/execute { action: 'update', params: { ... } }
- **Resultado esperado:** 200 OK, data = objeto actualizado, success = true

### Caso 5: Baja lógica
- **Input:** id = 10
- **Acción:** POST /api/execute { action: 'delete', params: { id: 10 } }
- **Resultado esperado:** 200 OK, data = { id: 10, deleted: true }, success = true

### Caso 6: Consulta con clave inexistente
- **Input:** cvecatnva = 'ZZZZZZZZZZZ'
- **Acción:** POST /api/execute { action: 'list', params: { cvecatnva: 'ZZZZZZZZZZZ' } }
- **Resultado esperado:** 200 OK, data = [], success = true
