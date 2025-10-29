## Casos de Prueba para consuem400

### Caso 1: Consulta exitosa
- **Entrada:** recaud=1, ur=0, cuenta=12345
- **Acción:** Buscar
- **Resultado esperado:**
  - success: true
  - message: 'Registros encontrados'
  - data: [ { ... } ] (al menos un registro)

### Caso 2: Consulta sin resultados
- **Entrada:** recaud=99, ur=9, cuenta=99999
- **Acción:** Buscar
- **Resultado esperado:**
  - success: false
  - message: 'No se localizaron registros históricos del AS400'
  - data: []

### Caso 3: Parámetros incompletos
- **Entrada:** recaud=1, ur=0, cuenta=null
- **Acción:** Buscar
- **Resultado esperado:**
  - success: false
  - message: 'Parámetros requeridos: recaud, ur, cuenta'

### Caso 4: Error de comunicación
- **Simulación:** El backend no responde o lanza excepción
- **Resultado esperado:**
  - success: false
  - message: 'Error de comunicación con el servidor' (en frontend)

### Caso 5: Cierre de sesión
- **Acción:** close
- **Resultado esperado:**
  - success: true
  - message: 'Sesión cerrada'
