## Casos de Prueba ReqTrans

### 1. Alta exitosa de requerimiento
- **Entrada**: Todos los campos obligatorios completos y válidos
- **Acción**: POST /api/execute { action: 'create', ... }
- **Esperado**: success=true, id devuelto, registro creado en DB

### 2. Alta con campos faltantes
- **Entrada**: Falta 'tipo' o 'cvecta'
- **Acción**: POST /api/execute { action: 'create', ... }
- **Esperado**: success=false, mensaje de error de validación

### 3. Consulta por folio existente
- **Entrada**: folio válido existente
- **Acción**: POST /api/execute { action: 'list', folio: ... }
- **Esperado**: success=true, data con los datos del requerimiento

### 4. Consulta por folio inexistente
- **Entrada**: folio no existente
- **Acción**: POST /api/execute { action: 'list', folio: ... }
- **Esperado**: success=true, data vacía

### 5. Actualización exitosa
- **Entrada**: id existente, datos válidos
- **Acción**: POST /api/execute { action: 'update', ... }
- **Esperado**: success=true, mensaje de éxito

### 6. Eliminación exitosa
- **Entrada**: id existente
- **Acción**: POST /api/execute { action: 'delete', id: ... }
- **Esperado**: success=true, mensaje de éxito

### 7. Catálogo de ejecutores
- **Entrada**: action: 'catalog', table: 'ejecutor'
- **Acción**: POST /api/execute { action: 'catalog', table: 'ejecutor' }
- **Esperado**: success=true, data con lista de ejecutores

### 8. Consulta de datos generales de folio
- **Entrada**: action: 'folio_data', foliotrans: ...
- **Acción**: POST /api/execute { action: 'folio_data', foliotrans: ... }
- **Esperado**: success=true, data con los datos generales
