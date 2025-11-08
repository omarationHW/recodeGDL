## Casos de Prueba para Emisión Libertad

### Caso 1: Generar emisión para un mercado válido
- **Entrada:** oficina=1, mercados=[5], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=true, data contiene array de locales con campos requeridos.

### Caso 2: Exportar archivo TXT de emisión
- **Entrada:** oficina=1, mercados=[5,6], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'exportarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=true, data.file_url contiene URL válida para descarga.

### Caso 3: Error por parámetros faltantes
- **Entrada:** oficina=1, mercados=[], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=false, message indica error de parámetros.

### Caso 4: Error por recaudadora inexistente
- **Entrada:** oficina=999, mercados=[5], axo=2024, periodo=6, usuario_id=1
- **Acción:** POST /api/execute { action: 'generarEmisionLibertad', params: {...} }
- **Resultado esperado:** status 200, success=false, message indica recaudadora no encontrada.

### Caso 5: Visualización de detalle
- **Entrada:** oficina=1, mercados=[5,6], axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionLibertadDetalle', params: {...} }
- **Resultado esperado:** status 200, success=true, data contiene detalle de emisión.
