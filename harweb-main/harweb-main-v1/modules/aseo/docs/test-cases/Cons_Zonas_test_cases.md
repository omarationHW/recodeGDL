# Casos de Prueba: Consulta de Zonas

## Caso 1: Consulta inicial
- **Acción:** Acceder a la página de Consulta de Zonas.
- **Esperado:** Se muestran todas las zonas ordenadas por 'Control'.
- **Validación:** El primer registro corresponde al menor valor de 'ctrol_zona'.

## Caso 2: Cambio de orden
- **Acción:** Seleccionar 'Descripción' como orden.
- **Esperado:** La tabla se reordena alfabéticamente por 'descripcion'.
- **Validación:** El primer registro corresponde a la descripción alfabéticamente menor.

## Caso 3: Exportar a Excel
- **Acción:** Hacer clic en 'Exportar Excel'.
- **Esperado:** Se descarga un archivo CSV con los datos actuales.
- **Validación:** El archivo contiene los mismos datos que la tabla y puede abrirse en Excel.

## Caso 4: Sin datos
- **Acción:** Si la tabla ta_16_zonas está vacía.
- **Esperado:** La tabla muestra 'No hay datos'.
- **Validación:** No se produce error y el botón de exportar muestra alerta de 'No hay datos para exportar'.

## Caso 5: Error de backend
- **Acción:** Simular error en el stored procedure (por ejemplo, campo de orden inválido).
- **Esperado:** El frontend muestra mensaje de error amigable.
- **Validación:** El usuario ve el mensaje y no se rompe la interfaz.
