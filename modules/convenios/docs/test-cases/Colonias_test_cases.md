## Casos de Prueba para Catálogo de Colonias

### 1. Alta exitosa de colonia
- **Entrada:**
  - colonia: 200
  - descripcion: "Colonia Prueba"
  - id_rec: 1
  - id_zona: 2
  - col_obra94: null
  - id_usuario: 1
- **Acción:** colonias.create
- **Esperado:** success=true, message="Colonia creada correctamente"

### 2. Alta duplicada (clave existente)
- **Entrada:**
  - colonia: 200 (ya existe)
  - descripcion: "Colonia Duplicada"
  - id_rec: 1
  - id_zona: 2
  - col_obra94: null
  - id_usuario: 1
- **Acción:** colonias.create
- **Esperado:** success=false, message="Ya existe una colonia con ese código"

### 3. Edición exitosa
- **Entrada:**
  - colonia: 200
  - descripcion: "Colonia Prueba Editada"
  - id_rec: 1
  - id_zona: 3
  - col_obra94: 5
  - id_usuario: 1
- **Acción:** colonias.update
- **Esperado:** success=true, message="Colonia actualizada correctamente"

### 4. Edición de colonia inexistente
- **Entrada:**
  - colonia: 9999
  - descripcion: "No existe"
  - id_rec: 1
  - id_zona: 2
  - col_obra94: null
  - id_usuario: 1
- **Acción:** colonias.update
- **Esperado:** success=false, message="Colonia no encontrada"

### 5. Eliminación exitosa
- **Entrada:**
  - colonia: 200
- **Acción:** colonias.delete
- **Esperado:** success=true, message="Colonia eliminada correctamente"

### 6. Eliminación de colonia inexistente
- **Entrada:**
  - colonia: 9999
- **Acción:** colonias.delete
- **Esperado:** success=false, message="Colonia no encontrada"

### 7. Listado de colonias
- **Entrada:**
  - (sin parámetros)
- **Acción:** colonias.list
- **Esperado:** success=true, data=[...]

### 8. Reporte de colonias
- **Entrada:**
  - (sin parámetros)
- **Acción:** colonias.report
- **Esperado:** success=true, data=[...]
