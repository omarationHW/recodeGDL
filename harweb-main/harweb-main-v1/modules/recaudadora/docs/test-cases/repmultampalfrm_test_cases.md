# Casos de Prueba para Reporte de Multas Municipales

| Caso | Descripción | Datos de Entrada | Resultado Esperado |
|------|-------------|------------------|-------------------|
| TC01 | Consulta sin filtros (Todos) | Sin filtros (todos por default) | Se muestran todas las multas existentes |
| TC02 | Consulta por dependencia y rango de fechas | Dependencia: 2, Fecha inicio: 2024-01-01, Fecha fin: 2024-03-31, Tipo fecha: Rango | Solo multas de la dependencia 2 en ese rango |
| TC03 | Consulta por nombre de contribuyente | Nombre: 'PEDRO', Tipo fecha: Todos | Solo multas cuyo contribuyente inicia con 'PEDRO' |
| TC04 | Consulta por año y estado vigente | Año: 2023, Estado: Vigente | Solo multas del año 2023 y con fecha_cancelacion NULL |
| TC05 | Consulta por infracción y domicilio | Infracción: 5, Domicilio: 'CALLE 10', Estado: Todos | Solo multas con esa infracción y domicilio que inicia con 'CALLE 10' |
| TC06 | Consulta sin resultados | Dependencia: 99 (no existe) | Mensaje de 'No se encontraron resultados' |
| TC07 | Validación de campos requeridos | Tipo fecha: Rango, solo fecha inicio | Mensaje de error: 'Debe seleccionar fecha de inicio y fin.' |
| TC08 | Validación de año | Tipo fecha: Año, año vacío | Mensaje de error: 'Debe especificar el año.' |
