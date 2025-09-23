## Casos de Prueba para Rep_Zonas

### Caso 1: Reporte ordenado por Control
- **Acción:** Seleccionar 'Control' y hacer clic en 'Vista Previa'
- **Entrada:** order = 1
- **Esperado:** Respuesta eResponse.success = true, data ordenada por ctrol_zona ascendente

### Caso 2: Reporte ordenado por Zona
- **Acción:** Seleccionar 'Zona' y hacer clic en 'Vista Previa'
- **Entrada:** order = 2
- **Esperado:** Respuesta eResponse.success = true, data ordenada por zona, sub_zona

### Caso 3: Reporte ordenado por Sub-Zona
- **Acción:** Seleccionar 'Sub-Zona' y hacer clic en 'Vista Previa'
- **Entrada:** order = 3
- **Esperado:** Respuesta eResponse.success = true, data ordenada por sub_zona, zona

### Caso 4: Reporte ordenado por Descripción
- **Acción:** Seleccionar 'Descripción' y hacer clic en 'Vista Previa'
- **Entrada:** order = 4
- **Esperado:** Respuesta eResponse.success = true, data ordenada por descripcion, ctrol_zona

### Caso 5: Error de base de datos
- **Acción:** Simular caída de base de datos y ejecutar cualquier consulta
- **Entrada:** order = 1
- **Esperado:** Respuesta eResponse.success = false, eResponse.message contiene mensaje de error

### Caso 6: Acción no soportada
- **Acción:** Enviar action = 'noExiste'
- **Entrada:** action = 'noExiste'
- **Esperado:** Respuesta eResponse.success = false, eResponse.message = 'Acción no soportada'
