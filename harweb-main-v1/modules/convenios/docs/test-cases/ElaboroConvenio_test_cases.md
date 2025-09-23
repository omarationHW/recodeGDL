## Casos de Prueba ElaboroConvenio

### 1. Alta exitosa
- **Input:**
  ```json
  { "action": "create", "params": { "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "JPG", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" } }
  ```
- **Expected:**
  - HTTP 200, success: true, data contiene el registro creado.

### 2. Alta con datos faltantes
- **Input:**
  ```json
  { "action": "create", "params": { "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" } }
  ```
- **Expected:**
  - HTTP 200, success: false, message indica campo requerido.

### 3. Modificación exitosa
- **Input:**
  ```json
  { "action": "update", "params": { "id_control": 5, "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "JPGX", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" } }
  ```
- **Expected:**
  - HTTP 200, success: true, data contiene el registro actualizado.

### 4. Eliminación exitosa
- **Input:**
  ```json
  { "action": "delete", "params": { "id_control": 5 } }
  ```
- **Expected:**
  - HTTP 200, success: true, data contiene el id_control eliminado.

### 5. Listado
- **Input:**
  ```json
  { "action": "list", "params": {} }
  ```
- **Expected:**
  - HTTP 200, success: true, data es un array de registros.

### 6. Modificación con id_control inexistente
- **Input:**
  ```json
  { "action": "update", "params": { "id_control": 9999, "id_rec": 2, "id_usu_titular": 101, "iniciales_titular": "JPGX", "id_usu_elaboro": 202, "iniciales_elaboro": "MGA" } }
  ```
- **Expected:**
  - HTTP 200, success: true, data es null o vacío (no error, pero no actualiza nada).
