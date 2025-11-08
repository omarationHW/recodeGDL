## Casos de Prueba para RAdeudos_OpcMult

### Caso 1: Buscar local existente y mostrar adeudos
- **Entrada**: numero='123', letra='A'
- **Acción**: Buscar
- **Esperado**: Se muestran datos del local y lista de adeudos.

### Caso 2: Buscar local inexistente
- **Entrada**: numero='999', letra='Z'
- **Acción**: Buscar
- **Esperado**: Mensaje de error 'No existe LOCAL con este dato, intentalo de nuevo'.

### Caso 3: Ejecutar opción 'Dar de Pagado' con selección válida
- **Entrada**: Seleccionar adeudo(s), ingresar datos válidos, opción 'P'
- **Acción**: Ejecutar
- **Esperado**: Mensaje de éxito, adeudos actualizados a status 'Pagado'.

### Caso 4: Ejecutar opción sin seleccionar adeudos
- **Entrada**: No seleccionar ningún adeudo
- **Acción**: Ejecutar
- **Esperado**: Mensaje de error 'Debe seleccionar al menos un adeudo.'

### Caso 5: Error en proceso de actualización (ejemplo: status inválido)
- **Entrada**: Seleccionar adeudo, ingresar status inválido
- **Acción**: Ejecutar
- **Esperado**: Mensaje de error del backend.
