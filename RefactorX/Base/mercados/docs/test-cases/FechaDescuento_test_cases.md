# Casos de Prueba: FechaDescuento

| # | Descripción | Entrada | Resultado Esperado |
|---|-------------|---------|--------------------|
| 1 | Consulta de todos los meses | action: 'list' | Devuelve 12 filas con los datos de cada mes |
| 2 | Consulta de un mes específico | action: 'get', mes: 5 | Devuelve la fila del mes 5 |
| 3 | Modificación exitosa | action: 'update', mes: 7, fecha_descuento: '2024-07-15', fecha_recargos: '2024-07-25', id_usuario: 1 | success: true, message: 'Actualización exitosa' |
| 4 | Modificación con mes inexistente | action: 'update', mes: 13, ... | success: false, message: 'No existe el mes especificado' |
| 5 | Modificación con fecha inválida | action: 'update', mes: 6, fecha_descuento: '2024-13-01', ... | success: false, message de validación |
| 6 | Modificación sin usuario | action: 'update', mes: 6, fecha_descuento: '2024-06-10', fecha_recargos: '2024-06-20' | success: false, message de validación |
| 7 | Modificación sin cambios (mismos valores) | action: 'update', mes: 6, ... (valores actuales) | success: true, message: 'Actualización exitosa' |
