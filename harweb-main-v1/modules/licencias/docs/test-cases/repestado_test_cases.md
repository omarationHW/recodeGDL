## Casos de Prueba para Formulario repestado

### Caso 1: Consulta exitosa de trámite existente
- **Entrada:** id_tramite = 12345
- **Acción:** Buscar
- **Resultado esperado:** Se muestran los datos completos del trámite 12345.

### Caso 2: Consulta de trámite inexistente
- **Entrada:** id_tramite = 999999
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error "No se encontró el trámite."

### Caso 3: Impresión de reporte
- **Entrada:** id_tramite = 12345
- **Acción:** Buscar, luego Imprimir Reporte
- **Resultado esperado:** Se abre el PDF del reporte correspondiente.

### Caso 4: Validación de campo obligatorio
- **Entrada:** id_tramite vacío
- **Acción:** Buscar
- **Resultado esperado:** Mensaje de error "El parámetro id_tramite es requerido"

### Caso 5: Manejo de error de backend
- **Simulación:** Forzar error en la base de datos (por ejemplo, caída de conexión)
- **Acción:** Buscar cualquier trámite
- **Resultado esperado:** Mensaje de error técnico devuelto en el campo message de eResponse
