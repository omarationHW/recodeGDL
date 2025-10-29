## Casos de Prueba

### Caso 1: Conexión Exitosa
- **Entrada:** Usuario: cajero, Contraseña: c4j3r0
- **Acción:** Enviar eRequest: 'test_connection' con los datos.
- **Esperado:** eResponse.success = true, message = 'Conexión exitosa.', data contiene success=true.

### Caso 2: Usuario Incorrecto
- **Entrada:** Usuario: noexiste, Contraseña: cualquier
- **Acción:** Enviar eRequest: 'test_connection'.
- **Esperado:** eResponse.success = false, message = 'Usuario no existe.'

### Caso 3: Contraseña Incorrecta
- **Entrada:** Usuario: cajero, Contraseña: incorrecta
- **Acción:** Enviar eRequest: 'test_connection'.
- **Esperado:** eResponse.success = false, message = 'Usuario o contraseña incorrectos.'

### Caso 4: Listar Bases de Datos
- **Entrada:** eRequest: 'get_databases'
- **Acción:** Enviar petición sin parámetros.
- **Esperado:** eResponse.success = true, data es un array de bases de datos.

### Caso 5: Cerrar Conexión
- **Entrada:** eRequest: 'close_connection'
- **Acción:** Enviar petición.
- **Esperado:** eResponse.success = true, message = 'Connection closed (stateless API).'
