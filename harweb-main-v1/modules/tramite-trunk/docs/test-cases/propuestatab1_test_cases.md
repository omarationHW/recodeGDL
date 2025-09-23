# Casos de Prueba para propuestatab1

## Caso 1: Consulta de Cuenta Histórica
- **Entrada:** { "eRequest": { "action": "show", "params": { "cvecuenta": 12345 } } }
- **Esperado:** eResponse.success = true, eResponse.data contiene los datos de la cuenta 12345

## Caso 2: Consulta de Régimen de Propiedad
- **Entrada:** { "eRequest": { "action": "regimen", "params": { "cvecuenta": 12345 } } }
- **Esperado:** eResponse.success = true, eResponse.data contiene la tabla de régimen de propiedad

## Caso 3: Consulta de Pagos
- **Entrada:** { "eRequest": { "action": "pagos", "params": { "cvecuenta": 12345 } } }
- **Esperado:** eResponse.success = true, eResponse.data contiene la tabla de pagos

## Caso 4: Consulta de Condominio por Clave Catastral
- **Entrada:** { "eRequest": { "action": "condominio", "params": { "cvecatnva": "D6512345678" } } }
- **Esperado:** eResponse.success = true, eResponse.data contiene los datos del condominio

## Caso 5: Error por acción no soportada
- **Entrada:** { "eRequest": { "action": "noexiste", "params": {} } }
- **Esperado:** eResponse.success = false, eResponse.message = 'Acción no soportada'

## Caso 6: Error por cuenta inexistente
- **Entrada:** { "eRequest": { "action": "show", "params": { "cvecuenta": 999999 } } }
- **Esperado:** eResponse.success = true, eResponse.data = []
