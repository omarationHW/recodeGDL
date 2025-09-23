## Casos de Prueba: Catálogo de Intereses

### 1. Alta de Interés Válido
- **Entrada:** { axo: 2024, mes: 7, porcentaje: 1.25, id_usuario: 5 }
- **Acción:** POST /api/execute { eRequest: { operation: 'create', data: ... } }
- **Esperado:** success=true, registro creado, datos correctos

### 2. Alta de Interés con Porcentaje Inválido
- **Entrada:** { axo: 2024, mes: 7, porcentaje: 0, id_usuario: 5 }
- **Esperado:** success=false, message='El porcentaje debe ser mayor a 0.01'

### 3. Modificación de Interés Existente
- **Entrada:** { axo: 2023, mes: 6, porcentaje: 1.5, id_usuario: 5 }
- **Acción:** POST /api/execute { eRequest: { operation: 'update', data: ... } }
- **Esperado:** success=true, porcentaje actualizado

### 4. Eliminación de Interés Existente
- **Entrada:** { axo: 2022, mes: 12 }
- **Acción:** POST /api/execute { eRequest: { operation: 'delete', data: ... } }
- **Esperado:** success=true, registro eliminado

### 5. Consulta de Catálogo
- **Acción:** POST /api/execute { eRequest: { operation: 'list' } }
- **Esperado:** success=true, data=lista de intereses

### 6. Eliminación de Registro Inexistente
- **Entrada:** { axo: 1999, mes: 1 }
- **Esperado:** success=true, deleted=false

### 7. Alta de Registro Duplicado
- **Entrada:** { axo: 2024, mes: 7, porcentaje: 1.25, id_usuario: 5 } (ya existe)
- **Esperado:** success=false, message='Registro duplicado o clave primaria existente'
