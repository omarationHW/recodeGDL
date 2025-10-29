## Casos de Prueba para newsfrm

### Caso 1: Visualización de Cambios
- **Descripción:** El usuario accede a la página y visualiza la lista de cambios.
- **Pasos:**
  1. Acceder a /news
  2. Verificar que se muestra la lista de cambios
- **Resultado esperado:** Se muestran todas las notas de versión correctamente.

### Caso 2: Aceptar Cambios Correctamente
- **Descripción:** El usuario acepta los cambios y el sistema lo registra.
- **Pasos:**
  1. Acceder a /news
  2. Presionar 'Aceptar Cambios'
  3. Verificar que el botón cambia a 'Cambios Aceptados' y se deshabilita
- **Resultado esperado:** El sistema responde con éxito y el botón se actualiza.

### Caso 3: Error por Falta de user_id
- **Descripción:** El usuario intenta aceptar cambios sin user_id.
- **Pasos:**
  1. Acceder a /news
  2. Simular ausencia de user_id en el frontend
  3. Presionar 'Aceptar Cambios'
  4. Verificar que el sistema muestra un mensaje de error
- **Resultado esperado:** El sistema muestra un error indicando que user_id es requerido.

### Caso 4: API - eRequest desconocido
- **Descripción:** Se envía un eRequest no soportado.
- **Pasos:**
  1. POST a /api/execute con eRequest: 'unknown_request'
  2. Verificar respuesta
- **Resultado esperado:** El sistema responde con mensaje de error 'Unknown eRequest: unknown_request'.
