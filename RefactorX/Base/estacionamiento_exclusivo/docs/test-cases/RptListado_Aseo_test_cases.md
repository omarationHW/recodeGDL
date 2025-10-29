# Casos de Prueba para RptListado_Aseo

| Caso | Descripción | Parámetros | Resultado Esperado |
|------|-------------|------------|-------------------|
| 1 | Consulta todos los tipos, rango de contratos | vtipo: 'todos', xnum1: 1000, xnum2: 2000, vrec: 1, fecha_corte: '2024-06-30' | Lista de adeudos para contratos 1000-2000, todos los tipos, totales correctos |
| 2 | Consulta solo tipo 'ORDINARIO' | vtipo: 'ORDINARIO', xnum1: 0, xnum2: 0, vrec: 1, fecha_corte: '2024-06-30' | Solo adeudos tipo 'ORDINARIO', totales correctos |
| 3 | Consulta contrato específico en fecha límite | vtipo: 'todos', xnum1: 1234, xnum2: 1234, vrec: 1, fecha_corte: '2024-06-15' | Solo adeudo del contrato 1234, lógica de corte de mes aplicada |
| 4 | Consulta sin resultados | vtipo: 'ESPECIAL', xnum1: 9999, xnum2: 9999, vrec: 1, fecha_corte: '2024-06-30' | Lista vacía, totales en cero |
| 5 | Consulta con fecha_corte inválida | vtipo: 'todos', xnum1: 0, xnum2: 0, vrec: 1, fecha_corte: '2024-02-30' | Error de validación de fecha |

## Escenarios adicionales
- Consulta con xnum1 > xnum2: Debe devolver error o lista vacía.
- Consulta con vrec inexistente: Lista vacía.
- Consulta con tipo de aseo inexistente: Lista vacía.
- Consulta con fecha_corte en el futuro: Solo registros hasta esa fecha.
