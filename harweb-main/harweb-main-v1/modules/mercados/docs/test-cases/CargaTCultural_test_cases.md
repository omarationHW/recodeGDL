# Casos de Prueba: CargaTCultural

## Caso 1: Consulta de Adeudos
- **Entrada:** local_desde=100, local_hasta=105, periodo=2, axo=2024
- **Acción:** POST /api/execute { eRequest: 'getAdeudosTCultural', payload: { ... } }
- **Esperado:** Respuesta con lista de adeudos para los folios y periodo/año

## Caso 2: Validación de Folios Correctos
- **Entrada:** pagos=[{id_local:100, fecha_pago:'2024-04-10', rec:1, caja:'A', operacion:12345, partida:'P1', ...}, ...]
- **Acción:** POST /api/execute { eRequest: 'validatePagosTCultural', payload: { pagos } }
- **Esperado:** foliosErroneos = []

## Caso 3: Validación de Folios Erróneos
- **Entrada:** pagos=[{id_local:101, fecha_pago:'', rec:'', caja:'', operacion:'', partida:''}, ...]
- **Acción:** POST /api/execute { eRequest: 'validatePagosTCultural', payload: { pagos } }
- **Esperado:** foliosErroneos contiene 101

## Caso 4: Guardado de Pagos Correctos
- **Entrada:** pagos=[{id_local:100, ... todos los campos válidos ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** inserted=1, deleted=1

## Caso 5: Guardado con Folios Erróneos
- **Entrada:** pagos=[{id_local:102, ... campos vacíos ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** inserted=0, deleted=0, error en message

## Caso 6: Aplicación de Descuento
- **Entrada:** pagos=[{id_local:150, descuento:10, importe:1000, ...}]
- **Acción:** POST /api/execute { eRequest: 'savePagosTCultural', payload: { pagos } }
- **Esperado:** importe_pago registrado = 900
