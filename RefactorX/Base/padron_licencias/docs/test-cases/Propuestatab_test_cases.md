# Casos de Prueba para Propuestatab

## Caso 1: Consulta de Cuenta Histórica
- **Entrada**: { eRequest: { action: 'list', params: { cvecuenta: 123456 } } }
- **Esperado**: eResponse contiene los datos principales de la cuenta

## Caso 2: Consulta de Régimen de Propiedad
- **Entrada**: { eRequest: { action: 'regimen', params: { cvecuenta: 123456 } } }
- **Esperado**: eResponse contiene la lista de propietarios y porcentajes

## Caso 3: Consulta de Diferencias
- **Entrada**: { eRequest: { action: 'diferencias', params: { cvecuenta: 123456 } } }
- **Esperado**: eResponse contiene la lista de diferencias históricas

## Caso 4: Consulta de Observaciones AS-400
- **Entrada**: { eRequest: { action: 'obs400', params: { recaud: 1, urbrus: 'U', cuenta: 123456 } } }
- **Esperado**: eResponse contiene la lista de observaciones

## Caso 5: Consulta de Condominio
- **Entrada**: { eRequest: { action: 'condominio', params: { cvecatnva: 'A123456789' } } }
- **Esperado**: eResponse contiene los datos del condominio

## Caso 6: Error por cuenta inexistente
- **Entrada**: { eRequest: { action: 'list', params: { cvecuenta: 999999 } } }
- **Esperado**: eResponse.error indica 'Cuenta no encontrada'
