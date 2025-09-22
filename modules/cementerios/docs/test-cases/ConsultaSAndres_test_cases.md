# Casos de Prueba ConsultaSAndres

| Caso | Descripción | Entrada | Resultado Esperado |
|------|-------------|---------|--------------------|
| TC01 | Consulta inicial de registros | POST /api/execute {action: 'consultar_sanandres_paginated', params: {page:1, per_page:20}} | success: true, data.items.length <= 20, data.total >= 0 |
| TC02 | Navegación a página 2 | POST /api/execute {action: 'consultar_sanandres_paginated', params: {page:2, per_page:20}} | success: true, data.items.length <= 20 |
| TC03 | Consulta con per_page=5 | POST /api/execute {action: 'consultar_sanandres_paginated', params: {page:1, per_page:5}} | success: true, data.items.length <= 5 |
| TC04 | Consulta con página fuera de rango | POST /api/execute {action: 'consultar_sanandres_paginated', params: {page:999, per_page:20}} | success: true, data.items.length == 0 |
| TC05 | Error de base de datos | POST /api/execute {action: 'consultar_sanandres_paginated', params: {page:1, per_page:20}} (DB caída) | success: false, message contiene error |
| TC06 | Acción no reconocida | POST /api/execute {action: 'accion_inexistente'} | success: false, message: 'Acción no reconocida' |
| TC07 | Consulta directa sin paginación | POST /api/execute {action: 'consultar_sanandres'} | success: true, data: array de registros |
