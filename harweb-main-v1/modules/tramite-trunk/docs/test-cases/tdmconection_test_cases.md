## Casos de Prueba para Login y Conexión

### Caso 1: Login exitoso
- **Entrada:**
  - username: jdoe
  - password: 123456
- **Acción:**
  - POST /api/execute { eRequest: 'login', params: { username: 'jdoe', password: '123456' } }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.username = 'jdoe'
  - eResponse.data.fullname no vacío

### Caso 2: Login fallido (contraseña incorrecta)
- **Entrada:**
  - username: jdoe
  - password: wrongpass
- **Acción:**
  - POST /api/execute { eRequest: 'login', params: { username: 'jdoe', password: 'wrongpass' } }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Invalid credentials.'

### Caso 3: Visualización de último usuario
- **Entrada:**
  - POST /api/execute { eRequest: 'get_last_user' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.last_user = 'jdoe' (o el último usuario autenticado)

### Caso 4: Guardar último usuario
- **Entrada:**
  - POST /api/execute { eRequest: 'set_last_user', params: { username: 'jdoe' } }
- **Esperado:**
  - eResponse.success = true
  - eResponse.message = 'Last user updated.'

### Caso 5: Logout
- **Entrada:**
  - POST /api/execute { eRequest: 'logout' }
- **Esperado:**
  - eResponse.success = true
  - eResponse.message = 'Logged out.'
