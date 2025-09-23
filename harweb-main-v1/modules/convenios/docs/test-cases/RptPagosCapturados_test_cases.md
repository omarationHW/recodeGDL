# Casos de Prueba: RptPagosCapturados

## 1. Consulta exitosa de pagos capturados
- **Entrada:** { "eRequest": { "action": "getPagosCapturados", "params": { "subtipo": 1 } } }
- **Esperado:** HTTP 200, eResponse.success=true, eResponse.data es un array con al menos un registro, campos clave presentes.

## 2. Consulta sin parámetro subtipo
- **Entrada:** { "eRequest": { "action": "getPagosCapturados", "params": { } } }
- **Esperado:** HTTP 200, eResponse.success=false, eResponse.message contiene 'Parámetro subtipo requerido'.

## 3. Consulta de resumen de pagos
- **Entrada:** { "eRequest": { "action": "getPagosCapturadosResumen", "params": { "subtipo": 2 } } }
- **Esperado:** HTTP 200, eResponse.success=true, eResponse.data es un array agrupado por manzana y lote.

## 4. Acción no soportada
- **Entrada:** { "eRequest": { "action": "accionInexistente", "params": { } } }
- **Esperado:** HTTP 200, eResponse.success=false, eResponse.message contiene 'Acción no soportada'.

## 5. Error de base de datos (simulado)
- **Entrada:** { "eRequest": { "action": "getPagosCapturados", "params": { "subtipo": 999999 } } }
- **Esperado:** HTTP 200, eResponse.success=false, eResponse.message contiene error de base de datos o sin resultados.
