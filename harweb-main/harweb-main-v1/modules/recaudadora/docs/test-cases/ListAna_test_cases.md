# Casos de Prueba ListAna

| # | Descripción | Datos de Entrada | Resultado Esperado |
|---|-------------|------------------|-------------------|
| 1 | Consulta de cajas para fecha y recaudadora válidas | fecha: '2024-06-10', recaud: '1' | Lista de cajas no vacía |
| 2 | Consulta de cajas para fecha y recaudadora sin datos | fecha: '2024-01-01', recaud: '5' | Lista de cajas vacía |
| 3 | Generación de reporte con datos | fecha: '2024-06-10', recaud: '1', caja: 'A' | Totales, folios y detalle mostrados correctamente |
| 4 | Generación de reporte sin datos | fecha: '2024-01-01', recaud: '5', caja: 'Z' | Totales y folios en cero/vacío, tabla detalle vacía |
| 5 | Cambio de recaudadora actualiza cajas | Cambiar recaud de '1' a '2' | Combo de cajas se actualiza |
| 6 | Error de conexión a API | Desconectar backend | Mensaje de error visible en frontend |
| 7 | Validación de campos requeridos | No seleccionar fecha o recaud | Botón 'Imprimir' deshabilitado o error de validación |
