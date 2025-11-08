## Casos de Prueba para Mannto_Recaudadoras

### 1. Alta exitosa de recaudadora
- **Input:** { "action": "create", "payload": { "num_rec": 20, "descripcion": "Recaudadora Test" } }
- **Resultado esperado:** success: true, message: 'Recaudadora creada correctamente.'
- **Verificación:** La recaudadora aparece en la lista.

### 2. Alta duplicada (número ya existe)
- **Input:** { "action": "create", "payload": { "num_rec": 20, "descripcion": "Otra" } }
- **Resultado esperado:** success: false, message contiene 'YA EXISTE'

### 3. Baja exitosa (sin contratos asociados)
- **Preparación:** Crear recaudadora 21 sin contratos asociados.
- **Input:** { "action": "delete", "payload": { "num_rec": 21 } }
- **Resultado esperado:** success: true, message: 'Recaudadora eliminada correctamente.'

### 4. Baja fallida (con contratos asociados)
- **Preparación:** Asegurarse que recaudadora 1 tiene contratos asociados.
- **Input:** { "action": "delete", "payload": { "num_rec": 1 } }
- **Resultado esperado:** success: false, message contiene 'EXISTEN CONTRATOS'

### 5. Edición exitosa
- **Input:** { "action": "update", "payload": { "num_rec": 20, "descripcion": "Recaudadora Test Editada" } }
- **Resultado esperado:** success: true, message: 'Recaudadora actualizada correctamente.'

### 6. Edición fallida (no existe)
- **Input:** { "action": "update", "payload": { "num_rec": 9999, "descripcion": "No existe" } }
- **Resultado esperado:** success: false, message contiene 'No existe la recaudadora'

### 7. Listado general
- **Input:** { "action": "list" }
- **Resultado esperado:** success: true, data: array de recaudadoras
