## Casos de Prueba para Mannto_Gastos

### Caso 1: Alta de Gastos
- **Input:** sdzmg=150.00, porc1_req=10.5, porc2_embargo=15.0, porc3_secuestro=20.0
- **Acción:** POST /api/execute { action: 'gastos.create', payload: { ... } }
- **Esperado:** HTTP 200, success=true, mensaje 'Gastos creados correctamente.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver un registro con los valores ingresados

### Caso 2: Modificación de Gastos
- **Input:** sdzmg=160.00, porc1_req=12.0, porc2_embargo=18.0, porc3_secuestro=22.0
- **Acción:** POST /api/execute { action: 'gastos.update', payload: { ... } }
- **Esperado:** HTTP 200, success=true, mensaje 'Gastos actualizados correctamente.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver el registro actualizado

### Caso 3: Eliminación de Gastos
- **Input:** N/A
- **Acción:** POST /api/execute { action: 'gastos.delete' }
- **Esperado:** HTTP 200, success=true, mensaje 'Todos los gastos eliminados.'
- **Verificación:** SELECT * FROM ta_16_gastos debe devolver cero registros

### Caso 4: Validación de Ceros
- **Input:** sdzmg=0, porc1_req=0, porc2_embargo=0, porc3_secuestro=0
- **Acción:** POST /api/execute { action: 'gastos.create', payload: { ... } }
- **Esperado:** HTTP 200, success=false, mensaje de error de validación
- **Verificación:** No se inserta ningún registro

### Caso 5: Consulta de Gastos
- **Input:** N/A
- **Acción:** POST /api/execute { action: 'gastos.list' }
- **Esperado:** HTTP 200, success=true, data con los registros actuales
