# Casos de Prueba para Contrarecibos

## 1. Consulta de Contrarecibos por Fecha
- **Entrada:** fecha = '2024-06-01'
- **Acción:** POST /api/execute { eRequest: 'getContrarecibosByDate', params: { fecha: '2024-06-01' } }
- **Esperado:** Respuesta success=true, data es array de contrarecibos, message vacío.

## 2. Suma de Contrarecibos por Fecha
- **Entrada:** fecha = '2024-06-01'
- **Acción:** POST /api/execute { eRequest: 'sumContrarecibosByDate', params: { fecha: '2024-06-01' } }
- **Esperado:** Respuesta success=true, data.total es numérico >= 0.

## 3. Visualización de Detalle de Contrarecibo
- **Entrada:** contrarecibo = 123456
- **Acción:** POST /api/execute { eRequest: 'getContrareciboDetalle', params: { contrarecibo: 123456 } }
- **Esperado:** Respuesta success=true, data contiene todos los campos del contrarecibo.

## 4. Alta de Contrarecibo (SP Insert)
- **Entrada:** Todos los campos requeridos, param=1
- **Acción:** POST /api/execute { eRequest: 'createContrarecibo', params: { ... } }
- **Esperado:** Respuesta success=true, data[0].result = 'inserted'.

## 5. Modificación de Contrarecibo (SP Update)
- **Entrada:** Todos los campos requeridos, param=2
- **Acción:** POST /api/execute { eRequest: 'createContrarecibo', params: { ... } }
- **Esperado:** Respuesta success=true, data[0].result = 'updated'.

## 6. Baja de Contrarecibo (SP Delete)
- **Entrada:** Claves primarias, param=3
- **Acción:** POST /api/execute { eRequest: 'createContrarecibo', params: { ... } }
- **Esperado:** Respuesta success=true, data[0].result = 'deleted'.

## 7. Error de Parámetro Faltante
- **Entrada:** Sin fecha
- **Acción:** POST /api/execute { eRequest: 'getContrarecibosByDate', params: { } }
- **Esperado:** Respuesta success=false, message indica error de parámetro.
