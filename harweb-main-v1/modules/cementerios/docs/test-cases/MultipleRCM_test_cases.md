## Casos de Prueba: MultipleRCM

### Caso 1: Búsqueda básica
- **Entrada:** cementerio='G', clase=1, clase_alfa='', seccion=1, seccion_alfa='', linea=1, linea_alfa='', fosa=1, fosa_alfa='', cuenta=0
- **Acción:** POST /api/execute { action: 'searchRCM', params: {...} }
- **Esperado:** Respuesta success=true, data.length <= 100, cada registro cumple los filtros.

### Caso 2: Paginación
- **Entrada:** Igual a caso 1, pero cuenta=último control_rcm del resultado anterior
- **Acción:** POST /api/execute { action: 'searchRCM', params: {...} }
- **Esperado:** Respuesta success=true, data.length <= 100, todos los control_rcm > cuenta.

### Caso 3: Sin resultados
- **Entrada:** cementerio='X', clase=99, ... (valores que no existen)
- **Acción:** POST /api/execute { action: 'searchRCM', params: {...} }
- **Esperado:** success=true, data.length == 0

### Caso 4: Consulta de detalle
- **Entrada:** control_rcm=valor existente
- **Acción:** POST /api/execute { action: 'getRCMById', params: { control_rcm } }
- **Esperado:** success=true, data.length==1, data[0].control_rcm==control_rcm

### Caso 5: Error de parámetros
- **Entrada:** action='searchRCM', params faltantes
- **Esperado:** success=false, message indica error
