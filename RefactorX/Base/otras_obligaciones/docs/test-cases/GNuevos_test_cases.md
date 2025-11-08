## Casos de Prueba GNuevos

### Caso 1: Alta exitosa
- **Input**: Todos los campos válidos, control único
- **Esperado**: status=1, concepto_status='Registro creado correctamente'

### Caso 2: Control duplicado
- **Input**: control ya existente
- **Esperado**: status=0, concepto_status='Ya existe un registro con ese control'

### Caso 3: Falta concesionario
- **Input**: par_conces vacío
- **Esperado**: status=0, concepto_status='Falta el dato del CONCESIONARIO'

### Caso 4: Superficie <= 0
- **Input**: par_sup=0
- **Esperado**: status=0, concepto_status='Falta el dato de la SUPERFICIE'

### Caso 5: Año de inicio < 2020
- **Input**: par_Axo_Ini=2019
- **Esperado**: status=0, concepto_status='Falta el dato del AÑO de inicio de OBLIGACION'

### Caso 6: Validación frontend
- **Input**: Dejar campos obligatorios vacíos y presionar Aplicar
- **Esperado**: Mensaje de error en frontend antes de enviar al backend

### Caso 7: Error inesperado
- **Input**: Error de base de datos simulado
- **Esperado**: success=false, error con mensaje técnico
