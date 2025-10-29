## Casos de Prueba para InteresesMtto

### 1. Alta exitosa
- **Input:** { "action": "interesesmtto.create", "params": { "axo": 2024, "mes": 8, "porcentaje": 2.0, "id_usuario": 1 } }
- **Resultado esperado:** success=true, data[0].result='OK', el registro aparece en el listado.

### 2. Alta duplicada
- **Input:** { "action": "interesesmtto.create", "params": { "axo": 2024, "mes": 8, "porcentaje": 2.0, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='Ya existe un registro para ese año y mes'.

### 3. Modificación exitosa
- **Input:** { "action": "interesesmtto.update", "params": { "axo": 2024, "mes": 8, "porcentaje": 2.5, "id_usuario": 1 } }
- **Resultado esperado:** success=true, data[0].result='OK', el porcentaje se actualiza.

### 4. Modificación inexistente
- **Input:** { "action": "interesesmtto.update", "params": { "axo": 2023, "mes": 12, "porcentaje": 1.0, "id_usuario": 1 } }
- **Resultado esperado:** success=false, message='No existe el registro para ese año y mes'.

### 5. Eliminación exitosa
- **Input:** { "action": "interesesmtto.delete", "params": { "axo": 2024, "mes": 8 } }
- **Resultado esperado:** success=true, data[0].result='OK', el registro desaparece del listado.

### 6. Eliminación inexistente
- **Input:** { "action": "interesesmtto.delete", "params": { "axo": 2022, "mes": 1 } }
- **Resultado esperado:** success=false, message='No existe el registro para ese año y mes'.

### 7. Listado general
- **Input:** { "action": "interesesmtto.list" }
- **Resultado esperado:** success=true, data es un array de registros actuales.
