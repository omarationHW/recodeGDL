# Casos de Prueba: Estadística de Pagos y Adeudos

## Caso 1: Consulta exitosa
- **Entrada:** rec=1, axo=2024, mes=6, fecdsd='2024-06-01', fechst='2024-06-30'
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=ok, data es array con al menos un mercado, message='Estadística obtenida'

## Caso 2: Parámetros inválidos
- **Entrada:** rec='', axo='', mes='', fecdsd='', fechst=''
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=error, message indica parámetros inválidos

## Caso 3: Recaudadora sin mercados activos
- **Entrada:** rec=99, axo=2024, mes=6, fecdsd='2024-06-01', fechst='2024-06-30'
- **Acción:** getEstadisticaPagosyAdeudos
- **Esperado:** status=ok, data es array vacío, message='Estadística obtenida'

## Caso 4: Exportación no implementada
- **Entrada:** action=exportEstadisticaPagosyAdeudos
- **Esperado:** status=ok, message='Exportación en proceso (no implementado en este ejemplo)'

## Caso 5: Consulta de detalle de mercado
- **Entrada:** rec=1, mercado=1
- **Acción:** getMercadoDetalle
- **Esperado:** status=ok, data es array de locales, message='Detalle de mercado obtenido'
