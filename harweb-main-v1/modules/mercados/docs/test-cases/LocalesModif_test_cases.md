## Casos de Prueba para LocalesModif

### Caso 1: Modificación exitosa de nombre
- **Entrada**: Local vigente, nuevo nombre válido
- **Acción**: Buscar local, modificar nombre, enviar
- **Esperado**: Respuesta success=true, nombre actualizado, movimiento registrado

### Caso 2: Intento de modificar local inexistente
- **Entrada**: Datos de búsqueda que no existen
- **Acción**: Buscar local
- **Esperado**: Respuesta success=false, mensaje 'Local no encontrado'

### Caso 3: Bloqueo de local sin seleccionar clave de bloqueo
- **Entrada**: Movimiento 'Bloquear', sin clave de bloqueo
- **Acción**: Modificar
- **Esperado**: Respuesta success=false, mensaje de validación

### Caso 4: Desbloqueo de local con fecha final y observación
- **Entrada**: Movimiento 'Desbloquear', clave de bloqueo, fecha final, observación
- **Acción**: Modificar
- **Esperado**: Respuesta success=true, bloqueo actualizado

### Caso 5: Modificación con usuario no autenticado
- **Entrada**: Cualquier acción
- **Acción**: Llamar API sin token
- **Esperado**: Respuesta HTTP 401 Unauthorized
