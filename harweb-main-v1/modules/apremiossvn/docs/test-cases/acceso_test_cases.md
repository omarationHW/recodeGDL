## Casos de Prueba para Formulario Acceso

### 1. Login exitoso
- **Entrada:** usuario='juan', clave='abc123', ejercicio=2024
- **Acción:** POST /api/execute { eRequest: { action: 'login', params: { usuario, clave, ejercicio } } }
- **Esperado:** eResponse.success=true, eResponse.data contiene datos de usuario

### 2. Login con contraseña incorrecta
- **Entrada:** usuario='juan', clave='mala', ejercicio=2024
- **Acción:** POST /api/execute { eRequest: { action: 'login', params: { usuario, clave, ejercicio } } }
- **Esperado:** eResponse.success=false, eResponse.message='Usuario o contraseña incorrectos'

### 3. Login con ejercicio fuera de rango
- **Entrada:** usuario='juan', clave='abc123', ejercicio=1999
- **Acción:** POST /api/execute { eRequest: { action: 'login', params: { usuario, clave, ejercicio } } }
- **Esperado:** eResponse.success=false, eResponse.message='El ejercicio debe estar entre 2001 y 2024'

### 4. Guardar usuario en registro
- **Entrada:** usuario='juan'
- **Acción:** POST /api/execute { eRequest: { action: 'setUserRegistry', params: { usuario } } }
- **Esperado:** eResponse.success=true

### 5. Obtener datos de usuario
- **Entrada:** usuario='juan'
- **Acción:** POST /api/execute { eRequest: { action: 'getUser', params: { usuario } } }
- **Esperado:** eResponse.success=true, eResponse.data contiene datos de usuario
