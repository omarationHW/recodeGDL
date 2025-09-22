## Casos de Prueba: Catálogo de Zonas

### Caso 1: Alta exitosa
- **Input:** zona=20, sub_zona=5, descripcion='Zona Sur'
- **Acción:** zonas.create
- **Resultado esperado:** status=success, data contiene la nueva zona

### Caso 2: Alta duplicada
- **Input:** zona=1, sub_zona=2, descripcion='Zona Duplicada'
- **Acción:** zonas.create
- **Resultado esperado:** status=error, message='Ya existe una zona con esos datos'

### Caso 3: Edición exitosa
- **Input:** ctrol_zona=5, zona=1, sub_zona=2, descripcion='Zona Centro Editada'
- **Acción:** zonas.update
- **Resultado esperado:** status=success, data contiene la zona actualizada

### Caso 4: Eliminación con empresas relacionadas
- **Input:** ctrol_zona=3
- **Acción:** zonas.delete
- **Resultado esperado:** status=error, message='No se puede eliminar: existen empresas con esta zona.'

### Caso 5: Eliminación exitosa
- **Input:** ctrol_zona=8
- **Acción:** zonas.delete
- **Resultado esperado:** status=success, message='Zona eliminada correctamente'

### Caso 6: Consulta de listado
- **Acción:** zonas.list
- **Resultado esperado:** status=success, data es un array de zonas
