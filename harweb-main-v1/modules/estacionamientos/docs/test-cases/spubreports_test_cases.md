## Casos de Prueba para API y Frontend

### Caso 1: Reporte por Categoría
- **Input:**
  ```json
  { "eRequest": { "operation": "spubreports_list", "params": { "opc": 1 } } }
  ```
- **Expected:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con campos: categoria, descripcion, numesta, etc.

### Caso 2: Resumen por Categoría y Sector
- **Input:**
  ```json
  { "eRequest": { "operation": "spubreports_sector_summary", "params": {} } }
  ```
- **Expected:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con campos: categoria, descripcion, cant_j, capac_j, ...

### Caso 3: Relación de Adeudo y Pago
- **Input:**
  ```json
  { "eRequest": { "operation": "spubreports_adeudos", "params": {} } }
  ```
- **Expected:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con campos: numesta, nombre, adeudos_ant, adeudos_act, proyectado, etc.

### Caso 4: Estado de Cuenta Individual
- **Input:**
  ```json
  { "eRequest": { "operation": "spubreports_edocta", "params": { "numesta": 123 } } }
  ```
- **Expected:**
  - HTTP 200
  - eResponse.success = true
  - eResponse.data es un array con los datos del estacionamiento 123

### Caso 5: Operación no soportada
- **Input:**
  ```json
  { "eRequest": { "operation": "no_existe", "params": {} } }
  ```
- **Expected:**
  - HTTP 200
  - eResponse.success = false
  - eResponse.error = 'Operación no soportada'
