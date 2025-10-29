## Casos de Prueba para Formulario impno

### Caso 1: Consulta exitosa de notificación
- **Entrada:**
  - recaud: '001'
  - urbrus: 'U'
  - cuenta: '12345'
- **Acción:** Buscar notificación
- **Esperado:**
  - Se muestran los datos completos de la notificación
  - El botón de imprimir está habilitado

### Caso 2: Campos obligatorios vacíos
- **Entrada:**
  - recaud: ''
  - urbrus: 'U'
  - cuenta: ''
- **Acción:** Buscar notificación
- **Esperado:**
  - Mensaje de error: 'No se han asignado los datos completos ...'

### Caso 3: Tipo de predio inválido
- **Entrada:**
  - recaud: '001'
  - urbrus: 'X'
  - cuenta: '12345'
- **Acción:** Buscar notificación
- **Esperado:**
  - Mensaje de error: 'Error en el tipo de predio, verificar ...'

### Caso 4: Registro no encontrado
- **Entrada:**
  - recaud: '999'
  - urbrus: 'U'
  - cuenta: '99999'
- **Acción:** Buscar notificación
- **Esperado:**
  - Mensaje de error: 'No se encontró el registro.'

### Caso 5: Impresión de notificación
- **Precondición:** Se ha consultado exitosamente una notificación
- **Acción:** Presionar 'Imprimir Notificación'
- **Esperado:**
  - Mensaje de éxito: 'Notificación impresa correctamente (simulado).'
