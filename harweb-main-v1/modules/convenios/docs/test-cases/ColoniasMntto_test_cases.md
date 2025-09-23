## Casos de Prueba para ColoniasMntto

### 1. Alta exitosa de colonia
- **Entrada:** colonia=200, descripcion='COLONIA TEST', id_rec=2, id_zona=1, col_obra94=0
- **Acción:** colonias.create
- **Esperado:** success=true, message='Colonia insertada correctamente', la colonia aparece en el listado

### 2. Alta duplicada
- **Entrada:** colonia=200 (ya existe), descripcion='COLONIA DUPLICADA', id_rec=2, id_zona=1, col_obra94=0
- **Acción:** colonias.create
- **Esperado:** success=false, message='La colonia ya existe'

### 3. Edición exitosa
- **Entrada:** colonia=200, descripcion='COLONIA EDITADA', id_rec=2, id_zona=2, col_obra94=1
- **Acción:** colonias.update
- **Esperado:** success=true, message='Colonia actualizada correctamente', los cambios reflejados en el listado

### 4. Edición de colonia inexistente
- **Entrada:** colonia=9999 (no existe), ...
- **Acción:** colonias.update
- **Esperado:** success=false, message='La colonia no existe'

### 5. Eliminación exitosa
- **Entrada:** colonia=200
- **Acción:** colonias.delete
- **Esperado:** success=true, message='Colonia eliminada correctamente', la colonia ya no aparece en el listado

### 6. Eliminación de colonia inexistente
- **Entrada:** colonia=9999
- **Acción:** colonias.delete
- **Esperado:** success=false, message='La colonia no existe'

### 7. Validación de campos obligatorios
- **Entrada:** descripcion='', id_rec='', id_zona=''
- **Acción:** colonias.create
- **Esperado:** success=false, message indicando campos obligatorios faltantes
