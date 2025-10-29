## Casos de Prueba para Adeudos_Ins

### 1. Registro exitoso
- **Input:** Datos válidos de contrato, periodo, tipo de operación, cantidad y oficio.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: true, message: 'Exedencia registrada correctamente'.

### 2. Contrato inexistente
- **Input:** Contrato no existente.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Contrato no encontrado o fuera de rango de ejercicio'.

### 3. Fecha de exedencia menor al inicio de obligación
- **Input:** Fecha de exedencia anterior a aso_mes_oblig del contrato.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'La fecha de exedencia es menor al inicio de obligación'.

### 4. No existe cuota normal para el periodo
- **Input:** No hay cuota normal para el periodo.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'No existe cuota normal para el periodo'.

### 5. Exedencia duplicada
- **Input:** Ya existe exedencia/contenedor para el periodo y operación.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Ya existe exedencia/contenedor para este periodo'.

### 6. Año fuera de rango
- **Input:** Año menor a 1989 o mayor al actual.
- **Acción:** POST /api/execute { action: 'adeudos_ins_insert', params: {...} }
- **Resultado esperado:** success: false, message: 'Año fuera de rango permitido'.

### 7. Validación de contrato
- **Input:** Contrato válido.
- **Acción:** POST /api/execute { action: 'adeudos_ins_validate_contrato', params: {...} }
- **Resultado esperado:** success: true, contrato_id: ...

### 8. Validación de contrato no existente
- **Input:** Contrato no existente.
- **Acción:** POST /api/execute { action: 'adeudos_ins_validate_contrato', params: {...} }
- **Resultado esperado:** success: false, message: 'Contrato no encontrado o no vigente'.
