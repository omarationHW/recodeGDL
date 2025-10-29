## Casos de Prueba para Procesos

### Caso 1: Crear proceso válido
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "nombre": "Proceso QA", "descripcion": "Prueba de creación" } } }
  ```
- **Esperado:**
  - success: true
  - data contiene el proceso creado con nombre y descripción correctos

### Caso 2: Crear proceso sin nombre (inválido)
- **Entrada:**
  ```json
  { "eRequest": { "action": "create", "data": { "descripcion": "Sin nombre" } } }
  ```
- **Esperado:**
  - success: false
  - message: 'Nombre requerido'

### Caso 3: Listar procesos
- **Entrada:**
  ```json
  { "eRequest": { "action": "list" } }
  ```
- **Esperado:**
  - success: true
  - data: array de procesos

### Caso 4: Obtener proceso por ID existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "get", "data": { "id": 1 } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso con id=1

### Caso 5: Actualizar proceso existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "update", "data": { "id": 1, "nombre": "Nuevo Nombre", "descripcion": "Nueva descripción" } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso actualizado

### Caso 6: Eliminar proceso existente
- **Entrada:**
  ```json
  { "eRequest": { "action": "delete", "data": { "id": 1 } } }
  ```
- **Esperado:**
  - success: true
  - data: proceso eliminado

### Caso 7: Eliminar proceso inexistente
- **Entrada:**
  ```json
  { "eRequest": { "action": "delete", "data": { "id": 9999 } } }
  ```
- **Esperado:**
  - success: true
  - data: null o vacío
