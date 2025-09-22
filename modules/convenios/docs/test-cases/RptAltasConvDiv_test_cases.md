# Casos de Prueba: Altas de Convenios Diversos

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|-------------------|
| 1 | Consulta exitosa de altas por recaudadora y fechas | rec: 'ZC1', fecha1: '2024-01-01', fecha2: '2024-06-30' | Lista de convenios con todos los campos calculados |
| 2 | Exportación a Excel | rec: 'ZO2', fecha1: '2024-03-01', fecha2: '2024-03-31' | Archivo Excel descargado con los datos del reporte |
| 3 | Parámetros insuficientes | rec: '', fecha1: '', fecha2: '' | Mensaje de error 'Parámetros insuficientes' |
| 4 | Consulta sin resultados | rec: 'ZM4', fecha1: '2023-01-01', fecha2: '2023-01-31' | Lista vacía, mensaje 'No hay datos' |
| 5 | Validación de formato de fecha | rec: 'ZC5', fecha1: '2024-02-30', fecha2: '2024-03-01' | Mensaje de error por fecha inválida |

**Notas:**
- Todos los endpoints deben responder en formato eResponse.
- El reporte debe incluir los campos calculados (expediente, domicilio, estado, nomtipo, nomsubtipo).
- El export a Excel debe contener los mismos datos que la tabla en pantalla.
