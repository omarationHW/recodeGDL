## Casos de Prueba para ImpresionNva

### Caso 1: Carga inicial del formulario
- **Precondición:** Usuario autenticado.
- **Acción:** Acceder a la ruta '/impresion-nva'.
- **Esperado:** Se muestra la página sin campos y sin errores.

### Caso 2: Envío del formulario vacío
- **Precondición:** Página cargada.
- **Acción:** Presionar el botón 'Enviar'.
- **Esperado:** Se muestra mensaje de éxito: 'Formulario enviado correctamente.'

### Caso 3: Acción no soportada
- **Precondición:** Página cargada.
- **Acción:** Enviar manualmente una petición a '/api/execute' con `{ eRequest: { action: 'invalidAction', params: {} } }`.
- **Esperado:** Se muestra mensaje de error: 'Acción no soportada.'

### Caso 4: Error de backend
- **Precondición:** Simular error en el backend (por ejemplo, desconectar la base de datos).
- **Acción:** Presionar 'Enviar'.
- **Esperado:** Se muestra mensaje de error: 'Error interno del servidor.'
