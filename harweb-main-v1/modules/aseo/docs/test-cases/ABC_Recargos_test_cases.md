## Casos de Prueba para Catálogo de Recargos

### 1. Alta de Recargo Válido
- **Input:**
  - aso_mes_recargo: '2024-08-01'
  - porc_recargo: 2.0
  - porc_multa: 1.0
- **Acción:** POST /api/execute { action: 'recargos.create', params: {...} }
- **Resultado esperado:** success=true, message='Recargo creado correctamente.'

### 2. Alta de Recargo Duplicado
- **Input:**
  - aso_mes_recargo: '2024-08-01' (ya existe)
  - porc_recargo: 2.5
  - porc_multa: 1.5
- **Acción:** POST /api/execute { action: 'recargos.create', params: {...} }
- **Resultado esperado:** success=false, message='Ya existe un recargo para ese periodo.'

### 3. Modificación de Recargo Existente
- **Input:**
  - aso_mes_recargo: '2024-08-01'
  - porc_recargo: 3.0
  - porc_multa: 2.0
- **Acción:** POST /api/execute { action: 'recargos.update', params: {...} }
- **Resultado esperado:** success=true, message='Recargo actualizado correctamente.'

### 4. Eliminación de Recargo Existente
- **Input:**
  - aso_mes_recargo: '2024-08-01'
- **Acción:** POST /api/execute { action: 'recargos.delete', params: {...} }
- **Resultado esperado:** success=true, message='Recargo eliminado correctamente.'

### 5. Eliminación de Recargo Inexistente
- **Input:**
  - aso_mes_recargo: '2023-01-01' (no existe)
- **Acción:** POST /api/execute { action: 'recargos.delete', params: {...} }
- **Resultado esperado:** success=false, message='No existe el recargo para ese periodo.'
