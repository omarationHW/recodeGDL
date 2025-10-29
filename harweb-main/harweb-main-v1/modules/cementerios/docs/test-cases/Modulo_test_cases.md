## Casos de Prueba

### Caso 1: Validación de Usuario Correcto
- **Entrada:** usuario = 'jdoe', clave = '1234'
- **Acción:** POST /api/execute { action: 'getUserByCredentials', params: { usuario: 'jdoe', clave: '1234' } }
- **Esperado:** success: true, data[0].valido === true, data[0].id_usuario !== null

### Caso 2: Validación de Usuario Incorrecto
- **Entrada:** usuario = 'jdoe', clave = 'wrongpass'
- **Acción:** POST /api/execute { action: 'getUserByCredentials', params: { usuario: 'jdoe', clave: 'wrongpass' } }
- **Esperado:** success: true, data[0].valido === false

### Caso 3: Consulta de Hora Actual
- **Entrada:** (sin parámetros)
- **Acción:** POST /api/execute { action: 'getCurrentTime' }
- **Esperado:** success: true, data contiene hora válida (formato HH:MM:SS)

### Caso 4: Verificación de Nueva Versión Existente
- **Entrada:** proyecto = 'BasePHP', version = '1.0.0'
- **Acción:** POST /api/execute { action: 'checkNewVersion', params: { proyecto: 'BasePHP', version: '1.0.0' } }
- **Esperado:** success: true, data[0].hay_nueva === false

### Caso 5: Verificación de Nueva Versión No Existente
- **Entrada:** proyecto = 'BasePHP', version = '0.9.0'
- **Acción:** POST /api/execute { action: 'checkNewVersion', params: { proyecto: 'BasePHP', version: '0.9.0' } }
- **Esperado:** success: true, data[0].hay_nueva === true
