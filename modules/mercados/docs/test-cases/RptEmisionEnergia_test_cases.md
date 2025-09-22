## Casos de Prueba para Emisión de Recibos de Energía

### Caso 1: Consulta exitosa de recibos
- **Entrada:** oficina=5, mercado=1, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data contiene array de recibos con campos correctos

### Caso 2: Impresión de reporte
- **Entrada:** oficina=5, mercado=2, axo=2023, periodo=5
- **Acción:** POST /api/execute { action: 'printEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data.pdf_url contiene URL válida de PDF

### Caso 3: Parámetros inválidos
- **Entrada:** oficina=5, mercado='', axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=false, message indica error de validación

### Caso 4: Sin resultados
- **Entrada:** oficina=5, mercado=99, axo=2024, periodo=6 (mercado inexistente)
- **Acción:** POST /api/execute { action: 'getEmisionEnergia', params: ... }
- **Esperado:** HTTP 200, success=true, data es array vacío

### Caso 5: Error de base de datos
- **Simulación:** Desconectar base de datos y repetir consulta
- **Esperado:** HTTP 200, success=false, message indica error de conexión o excepción
