## Casos de Prueba: Catálogo Unidades de Recolección

### 1. Alta exitosa de unidad
- **Input:**
  - action: insert
  - data: { ejercicio: 2024, cve: 'A', descripcion: 'Unidad A', costo: 100.00, costo_exed: 200.00 }
- **Resultado esperado:** success=true, message='Unidad creada correctamente', la unidad aparece en la lista.

### 2. Alta duplicada (misma clave y ejercicio)
- **Input:**
  - action: insert
  - data: { ejercicio: 2024, cve: 'A', descripcion: 'Unidad A', costo: 100.00, costo_exed: 200.00 }
- **Resultado esperado:** success=false, message='Ya existe una clave para ese ejercicio'.

### 3. Baja exitosa de unidad sin contratos
- **Input:**
  - action: delete
  - data: { ctrol_recolec: 105 }
- **Resultado esperado:** success=true, message='Unidad eliminada correctamente'.

### 4. Baja fallida por contratos asociados
- **Input:**
  - action: delete
  - data: { ctrol_recolec: 101 }
- **Resultado esperado:** success=false, message='Existen contratos asociados a esta unidad. No se puede eliminar.'

### 5. Modificación exitosa
- **Input:**
  - action: update
  - data: { ctrol_recolec: 102, descripcion: 'Unidad tipo C', costo: 180.00, costo_exed: 300.00 }
- **Resultado esperado:** success=true, message='Unidad actualizada correctamente'.

### 6. Consulta de lista
- **Input:**
  - action: list
  - data: { ejercicio: 2024 }
- **Resultado esperado:** success=true, data contiene arreglo de unidades del ejercicio 2024.

### 7. Consulta individual
- **Input:**
  - action: get
  - data: { ctrol_recolec: 102 }
- **Resultado esperado:** success=true, data contiene los datos de la unidad 102.
