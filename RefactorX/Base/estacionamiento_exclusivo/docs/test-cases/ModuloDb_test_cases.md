## Casos de Prueba para ModuloDb

### Caso 1: Login exitoso
- **Entrada:**
  - eRequest: getUserByCredentials
  - params: { "username": "juan", "password": "1234" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene datos del usuario

### Caso 2: Login fallido (usuario incorrecto)
- **Entrada:**
  - eRequest: getUserByCredentials
  - params: { "username": "noexiste", "password": "1234" }
- **Esperado:**
  - eResponse.success = false
  - eResponse.message = 'Usuario y/o contraseña incorrectos o inactivo.'

### Caso 3: Fecha y hora del servidor
- **Entrada:**
  - eRequest: getCurrentTime
- **Esperado:**
  - eResponse.success = true
  - eResponse.data contiene fecha/hora actual (formato ISO)

### Caso 4: Conversión de fecha a letras
- **Entrada:**
  - eRequest: dateToWords
  - params: { "date": "2024-03-15" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data = '15 de Marzo de 2024'

### Caso 5: Verificación de versión existente
- **Entrada:**
  - eRequest: checkNewVersion
  - params: { "proyecto": "BasePHP", "version": "1.0.0" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.nueva_version = false

### Caso 6: Verificación de versión inexistente
- **Entrada:**
  - eRequest: checkNewVersion
  - params: { "proyecto": "BasePHP", "version": "9.9.9" }
- **Esperado:**
  - eResponse.success = true
  - eResponse.data.nueva_version = true
