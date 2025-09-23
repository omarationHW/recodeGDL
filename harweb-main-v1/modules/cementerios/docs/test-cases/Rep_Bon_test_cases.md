# Casos de Prueba para Rep_Bon

| Caso | Entrada | Acción | Resultado Esperado |
|------|---------|--------|--------------------|
| 1 | recaudadora=3, pendientes=true | listar | Lista de oficios pendientes para recaudadora 3 |
| 2 | recaudadora=2, pendientes=false | imprimir | Reporte de todos los oficios para recaudadora 2 |
| 3 | recaudadora=10, pendientes=true | listar | Error: 'Error en la Recaudadora' |
| 4 | recaudadora=1, pendientes=true | listar | 'No existen Registros' si no hay datos |
| 5 | recaudadora=5, pendientes=false | listar | Lista de todos los oficios para recaudadora 5 |

## Detalle de Pruebas

### Prueba 1: Consulta Pendientes
- Entrada: `{ "eRequest": { "action": "listar", "recaudadora": 3, "pendientes": true } }`
- Esperado: `eResponse.success == true` y `eResponse.data.length > 0`

### Prueba 2: Imprimir Todos
- Entrada: `{ "eRequest": { "action": "imprimir", "recaudadora": 2, "pendientes": false } }`
- Esperado: `eResponse.success == true`, `eResponse.report == true`

### Prueba 3: Error Recaudadora
- Entrada: `{ "eRequest": { "action": "listar", "recaudadora": 10, "pendientes": true } }`
- Esperado: `eResponse.success == false`, `eResponse.message == 'Error en la Recaudadora'`

### Prueba 4: Sin Registros
- Entrada: `{ "eRequest": { "action": "listar", "recaudadora": 1, "pendientes": true } }` (sin datos en BD)
- Esperado: `eResponse.success == false`, `eResponse.message == 'No existen Registros'`

### Prueba 5: Consulta Todos
- Entrada: `{ "eRequest": { "action": "listar", "recaudadora": 5, "pendientes": false } }`
- Esperado: `eResponse.success == true`, `eResponse.data.length >= 0`