## Casos de Prueba para passpropietariofrm

### 1. Autenticación exitosa
- **Entrada:** usuario: 'jdoe', password: 'firma123'
- **Acción:** login
- **Esperado:** success: true, message: 'Autenticación exitosa'

### 2. Firma electrónica incorrecta
- **Entrada:** usuario: 'jdoe', password: 'claveerronea'
- **Acción:** login
- **Esperado:** success: false, message: 'Firma electrónica incorrecta'

### 3. Usuario no válido
- **Entrada:** usuario: 'noexiste', password: 'cualquier'
- **Acción:** login
- **Esperado:** success: false, message: 'Usuario no válido'

### 4. Validación de firma electrónica (validate)
- **Entrada:** usuario: 'jdoe', password: 'firma123'
- **Acción:** validate
- **Esperado:** success: true, message: 'Firma válida'

### 5. Limpiar password
- **Acción:** clear
- **Esperado:** success: true, message: 'Password limpiado'

### 6. Mostrar usuario actual
- **Acción:** show, usuario: 'jdoe'
- **Esperado:** success: true, data.usuario: 'jdoe', data.password: ''

### 7. Cerrar formulario
- **Acción:** close
- **Esperado:** success: true, message: 'Formulario cerrado'
