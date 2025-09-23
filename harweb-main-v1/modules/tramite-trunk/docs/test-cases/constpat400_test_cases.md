# Casos de Prueba para Consulta de TP AS400

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| 1 | Consulta por fecha y recaudadora | fecha=20240101, recaud=5 | Se muestran registros de pagos y transmisiones para esa fecha y recaudadora |
| 2 | Consulta por operación y caja | operacion=12345, caja='B' | Se muestran registros que coinciden con operación y caja |
| 3 | Consulta sin resultados | fecha=20991231, recaud=99 | Mensaje de "No se localizaron pagos..." |
| 4 | Consulta sin filtros (todos vacíos) | (todos vacíos) | Se muestran todos los registros de ambas tablas |
| 5 | Consulta con solo caja | caja='A' | Se muestran todos los registros con caja='A' |
| 6 | Consulta con solo operación | operacion=54321 | Se muestran todos los registros con folio/opc_pag=54321 |
| 7 | Consulta con todos los filtros | fecha=20240101, recaud=5, operacion=12345, caja='A' | Solo los registros que coincidan con todos los filtros |

**Notas:**
- Verificar que los resultados de ambas tablas (pagos y transmisiones) correspondan a los filtros aplicados.
- Probar con datos reales y con datos inexistentes para validar ambos escenarios.
- Validar que el frontend muestre correctamente los mensajes de error y advertencia.
