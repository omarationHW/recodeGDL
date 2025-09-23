## Casos de Prueba para Catálogo Claves de Operación

### 1. Alta exitosa de clave
- **Entrada:**
  - action: insert
  - data: { "cve_operacion": "Z", "descripcion": "Prueba Z" }
- **Esperado:**
  - success: true
  - message: 'Clave de operación creada correctamente'
  - data: contiene la nueva clave

### 2. Alta duplicada
- **Entrada:**
  - action: insert
  - data: { "cve_operacion": "A", "descripcion": "Duplicada" }
- **Esperado:**
  - success: false
  - message: 'Ya existe una clave con ese valor'

### 3. Eliminación con pagos asociados
- **Entrada:**
  - action: delete
  - data: { "ctrol_operacion": 1 }
- **Esperado:**
  - success: false
  - message: 'No se puede eliminar: existen pagos asociados a esta clave.'

### 4. Eliminación exitosa
- **Entrada:**
  - action: delete
  - data: { "ctrol_operacion": 99 }
- **Esperado:**
  - success: true
  - message: 'Clave de operación eliminada correctamente'

### 5. Edición exitosa
- **Entrada:**
  - action: update
  - data: { "ctrol_operacion": 2, "cve_operacion": "B", "descripcion": "Editada" }
- **Esperado:**
  - success: true
  - message: 'Clave de operación actualizada correctamente'

### 6. Consulta de lista
- **Entrada:**
  - action: list
  - data: {}
- **Esperado:**
  - success: true
  - data: lista de claves
