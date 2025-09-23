## Casos de Prueba para Unidades de Recolección

### 1. Alta exitosa
- **Entrada:**
  - ejercicio_recolec: 2024
  - cve_recolec: 'K'
  - descripcion: 'Camión Compactador'
  - costo_unidad: 1500.00
  - costo_exed: 2000.00
- **Acción:** create
- **Esperado:** status: 'ok', ctrol_recolec asignado

### 2. Alta duplicada
- **Entrada:**
  - ejercicio_recolec: 2024
  - cve_recolec: 'K' (ya existe)
- **Acción:** create
- **Esperado:** error: 'clave ya existe'

### 3. Listado por ejercicio
- **Entrada:**
  - ejercicio: 2024
- **Acción:** list
- **Esperado:** Lista de unidades para 2024

### 4. Edición exitosa
- **Entrada:**
  - ctrol_recolec: 5
  - ejercicio_recolec: 2024
  - cve_recolec: 'K'
  - descripcion: 'Camión Compactador 2024'
  - costo_unidad: 1600.00
  - costo_exed: 2000.00
- **Acción:** update
- **Esperado:** status: 'ok'

### 5. Edición de unidad inexistente
- **Entrada:**
  - ctrol_recolec: 9999 (no existe)
- **Acción:** update
- **Esperado:** error: 'unidad no existe'

### 6. Eliminación exitosa
- **Entrada:**
  - ctrol_recolec: 7 (sin contratos)
- **Acción:** delete
- **Esperado:** status: 'ok'

### 7. Eliminación con contratos referenciados
- **Entrada:**
  - ctrol_recolec: 3 (referenciado)
- **Acción:** delete
- **Esperado:** error: 'existen contratos con esta unidad'
