# Casos de Prueba para PagosEspe

## 1. Autorización Exitosa
- **Entrada:** cvecuenta=12345, bimini=1, axoini=2023, bimfin=2, axofin=2023
- **Acción:** POST /api/execute { action: 'authorize', params: {...} }
- **Resultado esperado:** success=true, message='El pago ha sido autorizado...'
- **Verificación:** El registro aparece en la lista con estado 'VIGENTE'.

## 2. Autorización con Cuenta Exenta
- **Entrada:** cvecuenta=54321 (exenta), bimini=1, axoini=2023, bimfin=2, axofin=2023
- **Acción:** POST /api/execute { action: 'authorize', params: {...} }
- **Resultado esperado:** success=false, message='Cuenta exenta. No puede usar esta opción'

## 3. Cancelación de Pago Especial Vigente
- **Entrada:** cveaut=1001 (registro vigente)
- **Acción:** POST /api/execute { action: 'cancel', params: { cveaut: 1001 } }
- **Resultado esperado:** success=true, message='El pago autorizado cancelado...'
- **Verificación:** El registro aparece en la lista con estado 'CANCELADO'.

## 4. Cancelación de Pago Especial ya Cancelado
- **Entrada:** cveaut=1002 (cvepago=999999)
- **Acción:** POST /api/execute { action: 'cancel', params: { cveaut: 1002 } }
- **Resultado esperado:** success=false, message='El pago autorizado ya está cancelado...'

## 5. Listar Pagos Especiales
- **Entrada:** cvecuenta=12345
- **Acción:** POST /api/execute { action: 'list', params: { cvecuenta: 12345 } }
- **Resultado esperado:** success=true, data=[...]
- **Verificación:** La lista contiene los registros correctos para la cuenta.
