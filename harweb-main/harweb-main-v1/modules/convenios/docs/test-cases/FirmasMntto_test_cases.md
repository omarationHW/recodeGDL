## Casos de Prueba para FirmasMntto

### 1. Alta de Firma (campos obligatorios)
- **Entrada:** Todos los campos llenos, valores válidos.
- **Acción:** Enviar action=firmas.create
- **Esperado:** Registro exitoso, mensaje de éxito, registro aparece en listado.

### 2. Alta de Firma (campo faltante)
- **Entrada:** Falta 'titular'.
- **Acción:** Enviar action=firmas.create
- **Esperado:** Error de validación, mensaje 'Todos los campos son obligatorios'.

### 3. Modificación de Firma
- **Entrada:** Cambiar 'titular' de un registro existente.
- **Acción:** Enviar action=firmas.update
- **Esperado:** Actualización exitosa, mensaje de éxito, datos actualizados en listado.

### 4. Eliminación de Firma
- **Entrada:** recaudadora existente.
- **Acción:** Enviar action=firmas.delete
- **Esperado:** Eliminación exitosa, mensaje de éxito, registro ya no aparece en listado.

### 5. Consulta de Listado
- **Entrada:** action=firmas.list
- **Acción:** Enviar petición
- **Esperado:** Respuesta con arreglo de firmas existentes.

### 6. Consulta Individual
- **Entrada:** action=firmas.get, recaudadora existente
- **Acción:** Enviar petición
- **Esperado:** Respuesta con datos de la firma solicitada.

### 7. Eliminación de Firma Inexistente
- **Entrada:** recaudadora no existente
- **Acción:** Enviar action=firmas.delete
- **Esperado:** No error grave, mensaje de registro no encontrado o eliminado.
