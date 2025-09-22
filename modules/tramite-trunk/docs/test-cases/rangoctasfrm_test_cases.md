## Casos de Prueba para rangoctasfrm

### Caso 1: Impresión por recaudadora - datos válidos
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "print_by_recaudadora",
      "params": { "recaud": 5, "inicial": 1000, "final": 1050 }
    }
  }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con registros

### Caso 2: Impresión por capturista - datos válidos
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "print_by_capturista",
      "params": { "capturista": "sigonzal", "fecha_ini": "2024-01-01", "fecha_fin": "2024-01-31" }
    }
  }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array con registros

### Caso 3: Validación de campos requeridos (falta campo)
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "print_by_recaudadora",
      "params": { "recaud": 5, "inicial": "", "final": 1050 }
    }
  }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message indica el campo faltante

### Caso 4: Acción no soportada
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "accion_inexistente",
      "params": {}
    }
  }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = false
  - eResponse.message = 'Acción no soportada'

### Caso 5: Sin resultados
- **Entrada:**
  ```json
  {
    "eRequest": {
      "action": "print_by_capturista",
      "params": { "capturista": "usuario_inexistente", "fecha_ini": "2024-01-01", "fecha_fin": "2024-01-31" }
    }
  }
  ```
- **Esperado:**
  - Código 200
  - eResponse.success = true
  - eResponse.data es un array vacío
