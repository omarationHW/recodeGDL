## Casos de Prueba para ABC_Recaudadoras

### 1. Alta de recaudadora válida
- **Entrada:** num_rec=20, descripcion='Recaudadora Sur'
- **Acción:** insertRecaudadora
- **Esperado:** success=true, message='Recaudadora agregada correctamente.'

### 2. Alta de recaudadora duplicada
- **Entrada:** num_rec=20, descripcion='Otra'
- **Acción:** insertRecaudadora
- **Esperado:** success=false, message='Ya existe una recaudadora con ese número.'

### 3. Edición de recaudadora existente
- **Entrada:** num_rec=20, descripcion='Recaudadora Sur Editada'
- **Acción:** updateRecaudadora
- **Esperado:** success=true, message='Recaudadora actualizada correctamente.'

### 4. Edición de recaudadora inexistente
- **Entrada:** num_rec=99, descripcion='No existe'
- **Acción:** updateRecaudadora
- **Esperado:** success=false, message='No existe la recaudadora.'

### 5. Eliminación de recaudadora sin contratos
- **Entrada:** num_rec=20
- **Acción:** deleteRecaudadora
- **Esperado:** success=true, message='Recaudadora eliminada correctamente.'

### 6. Eliminación de recaudadora con contratos asociados
- **Entrada:** num_rec=1 (asumiendo que tiene contratos)
- **Acción:** deleteRecaudadora
- **Esperado:** success=false, message='No se puede eliminar: existen contratos asociados.'

### 7. Listado de recaudadoras
- **Acción:** getRecaudadoras
- **Esperado:** success=true, data=[...], message=''
