# Casos de Prueba: Carátula de Energía Eléctrica

## Caso 1: Consulta exitosa de carátula
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getEnergiaCaratula', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data contiene datos del local y energía

## Caso 2: Consulta de adeudos y recargos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getAdeudosEnergia', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data es array de adeudos con campo recargos calculado

## Caso 3: Consulta de requerimientos
- **Entrada:** id_local = 12345
- **Acción:** POST /api/execute { action: 'getRequerimientosEnergia', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=true, data es array de requerimientos

## Caso 4: Cálculo de recargos para adeudo específico
- **Entrada:** id_adeudo = 67890
- **Acción:** POST /api/execute { action: 'calcularRecargosEnergia', params: { id_adeudo: 67890 } }
- **Resultado esperado:** Código 200, success=true, data es el valor numérico de recargos

## Caso 5: Error por parámetro faltante
- **Entrada:** id_local no enviado
- **Acción:** POST /api/execute { action: 'getEnergiaCaratula', params: { } }
- **Resultado esperado:** Código 200, success=false, message indica parámetro requerido

## Caso 6: Error por acción no soportada
- **Entrada:** action = 'accionInexistente'
- **Acción:** POST /api/execute { action: 'accionInexistente', params: { id_local: 12345 } }
- **Resultado esperado:** Código 200, success=false, message indica acción no soportada
