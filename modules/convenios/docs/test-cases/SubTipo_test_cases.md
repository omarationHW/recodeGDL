## Casos de Prueba para SubTipo

### 1. Alta de SubTipo válido
- **Acción:** create_subtipo
- **Parámetros:**
  - tipo: 2
  - subtipo: 1
  - desc_subtipo: "Subtipo prueba"
  - cuenta_ingreso: 100200
  - id_usuario: 1
- **Esperado:**
  - success: true
  - data: contiene el nuevo registro

### 2. Alta de SubTipo duplicado
- **Acción:** create_subtipo
- **Parámetros:**
  - tipo: 2
  - subtipo: 1
  - desc_subtipo: "Duplicado"
  - cuenta_ingreso: 100200
  - id_usuario: 1
- **Esperado:**
  - success: false
  - message: error de duplicidad (clave primaria)

### 3. Edición de SubTipo inexistente
- **Acción:** update_subtipo
- **Parámetros:**
  - tipo: 99
  - subtipo: 99
  - desc_subtipo: "No existe"
  - cuenta_ingreso: 999999
  - id_usuario: 1
- **Esperado:**
  - success: true (pero data vacío o sin cambios)

### 4. Eliminación de SubTipo válido
- **Acción:** delete_subtipo
- **Parámetros:**
  - tipo: 2
  - subtipo: 1
- **Esperado:**
  - success: true
  - data: tipo y subtipo eliminados

### 5. Listado de SubTipos
- **Acción:** list_subtipos
- **Parámetros:** ninguno
- **Esperado:**
  - success: true
  - data: array de subtipos

### 6. Obtener último subtipo por tipo
- **Acción:** last_subtipo_by_tipo
- **Parámetros:**
  - tipo: 2
- **Esperado:**
  - success: true
  - data: registro con mayor subtipo para tipo=2
