# Casos de Prueba Consulta Predial

## Caso 1: Consulta de Cuenta Existente
- **Input:** { action: 'getCuenta', params: { recaud: 1, urbrus: 'U', cuenta: 123456 } }
- **Expected:** success=true, data contiene los datos de la cuenta.

## Caso 2: Consulta de Cuenta Inexistente
- **Input:** { action: 'getCuenta', params: { recaud: 99, urbrus: 'X', cuenta: 999999 } }
- **Expected:** success=true, data=[]

## Caso 3: Consulta de Saldos
- **Input:** { action: 'getSaldos', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene lista de saldos por año.

## Caso 4: Consulta de Recibos
- **Input:** { action: 'getRecibos', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene lista de recibos.

## Caso 5: Consulta de Requerimientos
- **Input:** { action: 'getRequerimientos', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene lista de requerimientos.

## Caso 6: Consulta de Régimen de Propiedad
- **Input:** { action: 'getRegimenPropiedad', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene lista de propietarios.

## Caso 7: Consulta de Valores
- **Input:** { action: 'getValores', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene lista de valores fiscales.

## Caso 8: Consulta de Ubicación
- **Input:** { action: 'getUbicacion', params: { cvecuenta: 123456 } }
- **Expected:** success=true, data contiene los datos de ubicación.

## Caso 9: Visualización de Gráfico
- **Input:** { action: 'getGraficoUrl', params: { clave_cat: 'D6512345678' } }
- **Expected:** success=true, data.url contiene la URL del visor cartográfico.
