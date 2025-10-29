## Casos de Prueba para Consulta Individual de Pagos del Local

### Caso 1: Consulta Exitosa
- **Entrada:** id_local=123, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 123, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=true, data contiene información del pago

### Caso 2: Pago No Encontrado
- **Entrada:** id_local=999, axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 999, axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica que no se encontró el pago

### Caso 3: Parámetros Inválidos
- **Entrada:** id_local=123, axo='', periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: 123, axo: '', periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica error de validación

### Caso 4: SQL Injection Attempt
- **Entrada:** id_local="1; DROP TABLE ta_11_pagos_local;--", axo=2024, periodo=6
- **Acción:** POST /api/execute { action: 'getPagoIndividual', params: { id_local: "1; DROP TABLE ta_11_pagos_local;--", axo: 2024, periodo: 6 } }
- **Esperado:** Respuesta success=false, message indica error de validación

### Caso 5: Consulta de Mercado
- **Entrada:** oficina=1, num_mercado_nvo=10
- **Acción:** POST /api/execute { action: 'getMercadoInfo', params: { oficina: 1, num_mercado_nvo: 10 } }
- **Esperado:** Respuesta success=true, data contiene información del mercado
