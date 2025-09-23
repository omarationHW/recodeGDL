# Casos de Prueba para RptAdeudosPredios

## Caso 1: Consulta exitosa de adeudos vigentes
- **Entrada:** subtipo=1, fecha_hasta='2024-06-10', estado='A'
- **Acción:** POST /api/execute { action: 'getAdeudosPredios', params: {...} }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=''
- **Validación:** La suma de los campos en la tabla coincide con los totales mostrados en el pie de la tabla.

## Caso 2: Consulta de saldo anterior
- **Entrada:** subtipo=2, fecha_desde='2024-01-01', fecha_hasta='2024-06-10', estado='A'
- **Acción:** POST /api/execute { action: 'getAdeudosPrediosSaldoAnt', params: {...} }
- **Resultado esperado:** HTTP 200, success=true, data=[...], message=''
- **Validación:** El campo saldo_anterior es correcto según los pagos previos a fecha_desde.

## Caso 3: Error por parámetro faltante
- **Entrada:** subtipo='', fecha_hasta='2024-06-10', estado='A'
- **Acción:** POST /api/execute { action: 'getAdeudosPredios', params: {...} }
- **Resultado esperado:** HTTP 200, success=false, data=null, message contiene 'subtipo es requerido' o similar.

## Caso 4: Consulta de subtipos
- **Entrada:** action: 'getSubtipos'
- **Acción:** POST /api/execute { action: 'getSubtipos' }
- **Resultado esperado:** HTTP 200, success=true, data=[{subtipo, desc_subtipo}, ...]

## Caso 5: Consulta de manzanas por subtipo
- **Entrada:** action: 'getManzanas', params: { subtipo: 1 }
- **Acción:** POST /api/execute { action: 'getManzanas', params: { subtipo: 1 } }
- **Resultado esperado:** HTTP 200, success=true, data=[{manzana}, ...]
