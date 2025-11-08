## Casos de Prueba para Registros Históricos (regHfrm)

### 1. Consulta de registros históricos
- **Entrada:** cvecuenta = 12345
- **Acción:** POST /api/execute { eRequest: 'get_historic_records', params: { cvecuenta: 12345 } }
- **Resultado esperado:** Respuesta JSON con success=true y lista de registros históricos (axocomp, nocomp)

### 2. Alta de registro histórico válido
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'create_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2 } }
- **Resultado esperado:** success=true, message='Historic record created', el registro aparece en la consulta

### 3. Alta de registro histórico con datos faltantes
- **Entrada:** cvecuenta = 12345, axocomp = null, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'create_historic_record', params: { cvecuenta: 12345, nocomp: 2 } }
- **Resultado esperado:** success=false, message indica error de validación

### 4. Edición de registro histórico
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2, nuevos valores axocomp=2025, nocomp=3
- **Acción:** POST /api/execute { eRequest: 'update_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2, new_axocomp: 2025, new_nocomp: 3 } }
- **Resultado esperado:** success=true, message='Historic record updated', el registro aparece actualizado

### 5. Eliminación de registro histórico
- **Entrada:** cvecuenta = 12345, axocomp = 2024, nocomp = 2
- **Acción:** POST /api/execute { eRequest: 'delete_historic_record', params: { cvecuenta: 12345, axocomp: 2024, nocomp: 2 } }
- **Resultado esperado:** success=true, message='Historic record deleted', el registro ya no aparece en la consulta

### 6. Consulta de registro inexistente
- **Entrada:** cvecuenta = 99999, axocomp = 1900, nocomp = 1
- **Acción:** POST /api/execute { eRequest: 'get_historic_record', params: { cvecuenta: 99999, axocomp: 1900, nocomp: 1 } }
- **Resultado esperado:** success=true, data=null
