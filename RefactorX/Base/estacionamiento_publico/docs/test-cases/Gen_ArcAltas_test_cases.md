# Casos de Prueba: Gen_ArcAltas

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Generar archivo con folios | Periodo con registros (2024-06-01 a 2024-06-30) | Archivo descargable con los folios del periodo |
| TC02 | Generar archivo sin folios | Periodo sin registros (2023-01-01 a 2023-01-31) | Mensaje: 'No hubo registros para generar el archivo de texto, intenta con otro' |
| TC03 | Cancelar operación | Cualquier periodo, cancelar antes de generar archivo | Formulario vuelve a estado inicial |
| TC04 | Error en proceso de remesa | Forzar error en SP (ej. fechas inválidas) | Mensaje de error devuelto por backend |
| TC05 | Validar formato de archivo | Descargar archivo generado | Archivo contiene campos separados por '|' y todos los registros del periodo |
