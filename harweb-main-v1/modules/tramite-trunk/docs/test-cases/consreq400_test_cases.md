## Casos de Prueba para consreq400

### Caso 1: Consulta exitosa
- **Entrada:**
  - Recaudadora: 1234
  - UR: 1
  - Cuenta: 789
- **Acción:** Buscar
- **Esperado:**
  - Se muestra una tabla con al menos un registro.
  - Mensaje: 'Consulta exitosa.'

### Caso 2: Consulta sin resultados
- **Entrada:**
  - Recaudadora: 9999
  - UR: 0
  - Cuenta: 1
- **Acción:** Buscar
- **Esperado:**
  - Tabla vacía.
  - Mensaje: 'No se localizaron requerimientos del AS400'

### Caso 3: Campos obligatorios vacíos
- **Entrada:**
  - Recaudadora: 1234
  - UR: 1
  - Cuenta: (vacío)
- **Acción:** Buscar
- **Esperado:**
  - Mensaje de error: 'Parámetros requeridos: ofnar, tpr, ctarfc.'

### Caso 4: Formato de parámetros
- **Entrada:**
  - Recaudadora: 5
  - UR: 0
  - Cuenta: 12
- **Acción:** Buscar
- **Esperado:**
  - El backend recibe ofnar='005', tpr='0', ctarfc='000012'.
  - (Verificar en logs o debug)

### Caso 5: Error de comunicación
- **Simulación:** Desconectar el backend o simular error de red.
- **Acción:** Buscar con cualquier dato.
- **Esperado:**
  - Mensaje: 'Error de comunicación con el servidor.'
