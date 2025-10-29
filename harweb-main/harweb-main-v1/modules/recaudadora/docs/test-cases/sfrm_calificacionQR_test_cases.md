## Casos de Prueba para Calificación QR

### Caso 1: Consulta Exitosa de Multa
- **Entrada:** id_multa = 12345
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = true
  - data.calificacion contiene los campos principales
  - data.articulos es un array con al menos un elemento
  - El QR generado contiene los datos correctos

### Caso 2: Consulta con ID Inexistente
- **Entrada:** id_multa = 999999
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = true
  - data.calificacion = null
  - data.articulos = []
  - El frontend muestra mensaje 'No hay multa con este dato'

### Caso 3: Error de Parámetro Faltante
- **Entrada:** No se envía id_multa
- **Acción:** POST /api/execute con eRequest = get_calificacion_qr_full
- **Resultado esperado:**
  - success = false
  - error indica parámetro faltante o error de ejecución

### Caso 4: Impresión
- **Precondición:** Consulta exitosa de multa
- **Acción:** Usuario presiona botón 'Imprimir'
- **Resultado esperado:**
  - Se abre el diálogo de impresión del navegador
  - Solo se imprime la información relevante (sin formulario ni navegación)
